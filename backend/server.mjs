import { createServer } from 'node:http';
import { createHash, randomBytes, scryptSync, timingSafeEqual } from 'node:crypto';
import { DatabaseSync } from 'node:sqlite';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const db = new DatabaseSync(join(dirname(fileURLToPath(import.meta.url)), 'proxyproof.sqlite'));
const deviceBindingEnabled = process.env.DEVICE_BINDING_ENABLED === 'true';
db.exec(`PRAGMA journal_mode=WAL;
CREATE TABLE IF NOT EXISTS users(id TEXT PRIMARY KEY,email TEXT UNIQUE NOT NULL,name TEXT NOT NULL,role TEXT NOT NULL,password_hash TEXT NOT NULL,device_id TEXT);
CREATE TABLE IF NOT EXISTS sessions(id TEXT PRIMARY KEY,faculty_id TEXT NOT NULL,class_name TEXT NOT NULL,room TEXT NOT NULL,started_at INTEGER NOT NULL,ends_at INTEGER NOT NULL,closed INTEGER NOT NULL DEFAULT 0);
CREATE TABLE IF NOT EXISTS tokens(token_hash TEXT PRIMARY KEY,session_id TEXT NOT NULL,expires_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS attendance(session_id TEXT NOT NULL,student_id TEXT NOT NULL,marked_at INTEGER NOT NULL,source TEXT NOT NULL,PRIMARY KEY(session_id,student_id));
CREATE TABLE IF NOT EXISTS auth_tokens(token_hash TEXT PRIMARY KEY,user_id TEXT NOT NULL,expires_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS device_change_requests(id TEXT PRIMARY KEY,student_id TEXT NOT NULL,new_device_id TEXT NOT NULL,created_at INTEGER NOT NULL,status TEXT NOT NULL DEFAULT 'pending');
`);
const seedText = readFileSync(join(root, 'lib/demo_data.dart'), 'utf8');
const users = [...seedText.matchAll(/DemoUser\(\s*name: '([^']+)',\s*email: '([^']+)',\s*role: DemoRole\.(teacher|student)/g)];
const demoPassword = 'demo';
const salt = 'proxyproof-local-demo';
const passwordHash = scryptSync(demoPassword, salt, 32).toString('hex');
const insertUser = db.prepare('INSERT OR IGNORE INTO users(id,email,name,role,password_hash) VALUES(?,?,?,?,?)');
for (const [, name, email, role] of users) insertUser.run(email, email, name, role, passwordHash);

const hash = value => createHash('sha256').update(value).digest('hex');
const json = (res, status, body) => { res.writeHead(status, { 'content-type': 'application/json', 'access-control-allow-origin': '*', 'access-control-allow-headers': 'authorization,content-type', 'access-control-allow-methods': 'GET,POST,DELETE,OPTIONS' }); res.end(JSON.stringify(body)); };
async function body(req) { let value=''; for await (const chunk of req) value += chunk; return value ? JSON.parse(value) : {}; }
function auth(req) {
  const raw = (req.headers.authorization || '').replace(/^Bearer /i, '');
  if (!raw) return null;
  return db.prepare('SELECT u.* FROM auth_tokens a JOIN users u ON u.id=a.user_id WHERE a.token_hash=? AND a.expires_at>?').get(hash(raw), Date.now()) || null;
}
function requireAuth(req,res,role) { const user=auth(req); if(!user){json(res,401,{error:'Sign in again to continue.'});return null;} if(role && user.role!==role){json(res,403,{error:'This action is not available for your account.'});return null;} return user; }
const server = createServer(async (req,res) => {
  if(req.method==='OPTIONS'){json(res,204,{});return;}
  try {
    const url=new URL(req.url,'http://localhost');
    if(req.method==='GET'&&url.pathname==='/health'){json(res,200,{status:'ok',users:users.length});return;}
    if(req.method==='POST'&&url.pathname==='/auth/login'){
      const b=await body(req); const email=String(b.email||'').trim().toLowerCase();
      const user=db.prepare('SELECT * FROM users WHERE email=? AND role=?').get(email,b.role);
      const candidate=scryptSync(String(b.password||''),salt,32); const expected=Buffer.from(user?.password_hash||passwordHash,'hex');
      if(!user||!timingSafeEqual(candidate,expected)){json(res,401,{error:'Email, role, or password is incorrect.'});return;}
      const device=String(b.deviceId||'');
      if(deviceBindingEnabled && !device){json(res,400,{error:'Device identity is required.'});return;}
      if(deviceBindingEnabled && user.device_id && user.device_id!==device){
        if(user.role==='student') db.prepare("INSERT INTO device_change_requests(id,student_id,new_device_id,created_at) SELECT ?,?,?,? WHERE NOT EXISTS(SELECT 1 FROM device_change_requests WHERE student_id=? AND new_device_id=? AND status='pending')").run(randomBytes(8).toString('hex'),user.id,device,Date.now(),user.id,device);
        json(res,403,{error:'This account is registered to another device. A device change request has been sent to faculty.'});return;
      }
      if(deviceBindingEnabled && !user.device_id) db.prepare('UPDATE users SET device_id=? WHERE id=?').run(device,user.id);
      const token=randomBytes(32).toString('base64url'); db.prepare('INSERT INTO auth_tokens VALUES(?,?,?)').run(hash(token),user.id,Date.now()+30*24*60*60*1000);
      json(res,200,{token,user:{id:user.id,email:user.email,name:user.name,role:user.role}});return;
    }
    if(req.method==='POST'&&url.pathname==='/sessions'){
      const user=requireAuth(req,res,'teacher'); if(!user)return; const b=await body(req);
      const id=randomBytes(4).toString('hex'); const now=Date.now(); const duration=Math.max(1,Math.min(60,Number(b.durationMinutes)||5));
      db.prepare('UPDATE sessions SET closed=1 WHERE faculty_id=? AND closed=0').run(user.id);
      db.prepare('INSERT INTO sessions(id,faculty_id,class_name,room,started_at,ends_at) VALUES(?,?,?,?,?,?)').run(id,user.id,String(b.className||'Computer Networks'),String(b.room||'B204'),now,now+duration*60000);
      json(res,201,{id,className:String(b.className||'Computer Networks'),room:String(b.room||'B204'),startedAt:now,endsAt:now+duration*60000});return;
    }
    if(req.method==='GET'&&url.pathname==='/sessions/active'){
      const user=requireAuth(req,res,'student'); if(!user)return;
      const active=db.prepare(`SELECT s.id,s.class_name AS className,s.room,s.started_at AS startedAt,s.ends_at AS endsAt,u.name AS facultyName FROM sessions s JOIN users u ON u.id=s.faculty_id WHERE s.closed=0 AND s.ends_at>? ORDER BY s.started_at DESC`).all(Date.now());
      json(res,200,{sessions:active});return;
    }
    const sessionMatch=url.pathname.match(/^\/sessions\/([a-f0-9]+)(?:\/(token|close|attendance|events))?$/);
    if(sessionMatch){
      const user=requireAuth(req,res); if(!user)return; const [,id,action]=sessionMatch; const session=db.prepare('SELECT * FROM sessions WHERE id=?').get(id);
      if(!session){json(res,404,{error:'Session not found.'});return;}
      if(user.role==='teacher'&&session.faculty_id!==user.id){json(res,403,{error:'This session belongs to another faculty account.'});return;}
      if(action==='token'&&req.method==='POST'){
        if(user.role!=='teacher'||session.closed||session.ends_at<=Date.now()){json(res,409,{error:'Session is no longer active.'});return;}
        const b=await body(req); const token=String(b.token||''); if(token.length<14){json(res,400,{error:'Rotating token is invalid.'});return;}
        db.prepare('DELETE FROM tokens WHERE expires_at<=?').run(Date.now()); db.prepare('INSERT OR REPLACE INTO tokens VALUES(?,?,?)').run(hash(token),id,Date.now()+12000);
        json(res,200,{accepted:true,expiresAt:Date.now()+12000});return;
      }
      if(action==='close'&&req.method==='POST'){
        if(user.role!=='teacher'){json(res,403,{error:'Only faculty can close a session.'});return;}
        db.prepare('UPDATE sessions SET closed=1 WHERE id=?').run(id); json(res,200,{closed:true});return;
      }
      if(action==='attendance'&&req.method==='GET'){
        if(user.role!=='teacher'){json(res,403,{error:'Only faculty can view the live roster.'});return;}
        const list=db.prepare(`SELECT u.id,u.name,u.email,a.marked_at,a.source FROM users u LEFT JOIN attendance a ON a.student_id=u.id AND a.session_id=? WHERE u.role='student' ORDER BY u.name`).all(id);
        json(res,200,{session:{id,className:session.class_name,room:session.room,startedAt:session.started_at,endsAt:session.ends_at,closed:!!session.closed},students:list});return;
      }
      if(action==='events'&&req.method==='GET'){
        if(user.role!=='teacher'){json(res,403,{error:'Only faculty can subscribe to roster updates.'});return;}
        res.writeHead(200,{'content-type':'text/event-stream','cache-control':'no-cache','access-control-allow-origin':'*'});
        const send=()=>{const list=db.prepare(`SELECT u.id,u.name,u.email,a.marked_at,a.source FROM users u LEFT JOIN attendance a ON a.student_id=u.id AND a.session_id=? WHERE u.role='student' ORDER BY u.name`).all(id);res.write(`data: ${JSON.stringify({students:list,session:{id,className:session.class_name,room:session.room,startedAt:session.started_at,endsAt:session.ends_at,closed:!!db.prepare('SELECT closed FROM sessions WHERE id=?').get(id).closed}})}\n\n`);};
        send(); const timer=setInterval(send,1800); req.on('close',()=>clearInterval(timer)); return;
      }
    }
    if(req.method==='POST'&&url.pathname==='/check-in'){
      const user=requireAuth(req,res,'student'); if(!user)return; const b=await body(req); const id=String(b.sessionId||''); const session=db.prepare('SELECT * FROM sessions WHERE id=?').get(id);
      if(!session||session.closed||session.ends_at<=Date.now()){json(res,409,{error:'This attendance session has ended.'});return;}
      if(deviceBindingEnabled && user.device_id!==String(b.deviceId||'')){json(res,403,{error:'This phone is not registered to this account.'});return;}
      const rssi=Number(b.rssi);
      if(!Number.isFinite(rssi)||rssi>0||rssi<-78){json(res,403,{error:'Signal is invalid or too weak to confirm you are in the room.'});return;}
      const valid=db.prepare('SELECT 1 FROM tokens WHERE token_hash=? AND session_id=? AND expires_at>?').get(hash(String(b.token||'')),id,Date.now());
      if(!valid){json(res,409,{error:'The session code expired. Keep Bluetooth on while nearby.'});return;}
      db.prepare('INSERT OR IGNORE INTO attendance VALUES(?,?,?,?)').run(id,user.id,Date.now(),'ble'); json(res,200,{marked:true,markedAt:Date.now()});return;
    }
    if(req.method==='GET'&&url.pathname==='/my-attendance'){
      const user=requireAuth(req,res,'student'); if(!user)return;
      const rows=db.prepare(`SELECT s.id,s.class_name,s.room,s.started_at,a.marked_at FROM attendance a JOIN sessions s ON s.id=a.session_id WHERE a.student_id=? ORDER BY s.started_at DESC`).all(user.id);
      const total=db.prepare('SELECT COUNT(*) AS count FROM sessions WHERE closed=1 OR ends_at<=?').get(Date.now()).count;
      const attended=db.prepare('SELECT COUNT(*) AS count FROM attendance a JOIN sessions s ON s.id=a.session_id WHERE a.student_id=? AND (s.closed=1 OR s.ends_at<=?)').get(user.id,Date.now()).count;
      json(res,200,{attendance:rows,totalSessions:total,attendedSessions:attended,percentage:total===0?0:Math.round(attended*100/total)});return;
    }
    if(req.method==='POST'&&url.pathname==='/sessions/manual-attendance'){
      const user=requireAuth(req,res,'teacher'); if(!user)return; const b=await body(req); const s=db.prepare('SELECT * FROM sessions WHERE id=? AND faculty_id=? AND closed=0').get(b.sessionId,user.id);
      if(!s){json(res,404,{error:'Active session not found.'});return;}
      const student=db.prepare("SELECT id FROM users WHERE id=? AND role='student'").get(b.studentId);if(!student){json(res,404,{error:'Student not found.'});return;}
      if(b.present===false)db.prepare('DELETE FROM attendance WHERE session_id=? AND student_id=?').run(s.id,student.id);else db.prepare('INSERT OR REPLACE INTO attendance VALUES(?,?,?,?)').run(s.id,student.id,Date.now(),'manual');
      json(res,200,{updated:true});return;
    }
    if(req.method==='GET'&&url.pathname==='/sessions/history'){
      const user=requireAuth(req,res,'teacher'); if(!user)return; const rows=db.prepare(`SELECT s.id,s.class_name,s.room,s.started_at,s.ends_at,s.closed,COUNT(a.student_id) AS present FROM sessions s LEFT JOIN attendance a ON a.session_id=s.id WHERE s.faculty_id=? GROUP BY s.id ORDER BY s.started_at DESC`).all(user.id);
      if(url.searchParams.get('format')==='csv'){
        res.writeHead(200,{'content-type':'text/csv; charset=utf-8','content-disposition':'attachment; filename="proxyproof-attendance.csv"','access-control-allow-origin':'*'});res.end('Session,Class,Room,Started,Present,Status\n'+rows.map(r=>[r.id,r.class_name,r.room,new Date(r.started_at).toISOString(),r.present,r.closed?'Closed':'Live'].map(x=>'"'+String(x).replaceAll('"','""')+'"').join(',')).join('\n'));return;
      }
      json(res,200,{sessions:rows});return;
    }
    if(req.method==='GET'&&url.pathname==='/device-requests'){
      const user=requireAuth(req,res,'teacher'); if(!user)return;
      const requests=db.prepare("SELECT r.id,r.created_at,u.name,u.email FROM device_change_requests r JOIN users u ON u.id=r.student_id WHERE r.status='pending' ORDER BY r.created_at").all();
      json(res,200,{requests});return;
    }
    const approval=url.pathname.match(/^\/device-requests\/([a-f0-9]+)\/approve$/);
    if(req.method==='POST'&&approval){
      const user=requireAuth(req,res,'teacher'); if(!user)return; const request=db.prepare("SELECT * FROM device_change_requests WHERE id=? AND status='pending'").get(approval[1]);
      if(!request){json(res,404,{error:'Pending device request not found.'});return;}
      db.prepare('UPDATE users SET device_id=? WHERE id=?').run(request.new_device_id,request.student_id);
      db.prepare("UPDATE device_change_requests SET status='approved' WHERE id=?").run(request.id);
      json(res,200,{approved:true});return;
    }
    json(res,404,{error:'Route not found.'});
  } catch(error) { console.error(error); json(res,500,{error:'Server error. Check the local service log.'}); }
});
const port=Number(process.env.PORT||8787); const host=process.env.HOST||'127.0.0.1'; server.listen(port,host,()=>console.log(`ProxyProof local SQL service listening on http://${host}:${port} (${users.length} seeded accounts; demo password: demo; device binding: ${deviceBindingEnabled?'enabled':'disabled'})`));
