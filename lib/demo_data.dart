class DemoUser {
  const DemoUser({required this.name, required this.email, required this.role});

  final String name;
  final String email;
  final DemoRole role;
}

enum DemoRole { teacher, student }

class DemoClass {
  const DemoClass({
    required this.name,
    required this.room,
    required this.teacherEmail,
  });

  final String name;
  final String room;
  final String teacherEmail;
}

class DemoSession {
  const DemoSession({
    required this.className,
    required this.startedAt,
    required this.presentCount,
    required this.enrolledCount,
  });

  final String className;
  final String startedAt;
  final int presentCount;
  final int enrolledCount;
}

/// In-memory seed data used until the authentication and database services land.
class DemoDatabase {
  static const teachers = <DemoUser>[
    DemoUser(
      name: 'Alex Morgan',
      email: 'alex.morgan@proxyproof.demo',
      role: DemoRole.teacher,
    ),
    DemoUser(
      name: 'Priya Shah',
      email: 'priya.shah@proxyproof.demo',
      role: DemoRole.teacher,
    ),
  ];

  static const students = <DemoUser>[
    DemoUser(
      name: 'Aarav Mehta',
      email: 'aarav.mehta@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Isha Kapoor',
      email: 'isha.kapoor@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Kabir Shah',
      email: 'kabir.shah@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Mira Rao',
      email: 'mira.rao@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Reyansh Das',
      email: 'reyansh.das@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Ananya Iyer',
      email: 'ananya.iyer@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Dev Malhotra',
      email: 'dev.malhotra@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Diya Nair',
      email: 'diya.nair@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Arjun Menon',
      email: 'arjun.menon@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Zoya Khan',
      email: 'zoya.khan@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Vihaan Joshi',
      email: 'vihaan.joshi@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Sana Bhat',
      email: 'sana.bhat@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Aditya Verma',
      email: 'aditya.verma@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Aditi Kulkarni',
      email: 'aditi.kulkarni@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Ayaan Desai',
      email: 'ayaan.desai@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Avni Sethi',
      email: 'avni.sethi@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Dhruv Patel',
      email: 'dhruv.patel@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Ira Chawla',
      email: 'ira.chawla@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Kian Thomas',
      email: 'kian.thomas@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Kavya Reddy',
      email: 'kavya.reddy@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Neel Joshi',
      email: 'neel.joshi@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Myra Sen',
      email: 'myra.sen@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Rohan Gupta',
      email: 'rohan.gupta@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Tara Menon',
      email: 'tara.menon@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Samar Gill',
      email: 'samar.gill@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Nisha Pillai',
      email: 'nisha.pillai@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Parth Bansal',
      email: 'parth.bansal@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Rhea Dsouza',
      email: 'rhea.dsouza@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Yash Oberoi',
      email: 'yash.oberoi@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Kiara Fernandes',
      email: 'kiara.fernandes@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Om Prakash',
      email: 'om.prakash@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Shreya Mukherjee',
      email: 'shreya.mukherjee@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Ishaan Bhattacharya',
      email: 'ishaan.bhattacharya@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Meera Krishnan',
      email: 'meera.krishnan@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Atharv Sinha',
      email: 'atharv.sinha@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Pooja Nair',
      email: 'pooja.nair@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Rahul Nambiar',
      email: 'rahul.nambiar@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Saanvi Bose',
      email: 'saanvi.bose@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Manav Choudhary',
      email: 'manav.choudhary@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Anika Hegde',
      email: 'anika.hegde@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Advik Kaur',
      email: 'advik.kaur@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Hridhaan Roy',
      email: 'hridhaan.roy@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Tanvi Deshpande',
      email: 'tanvi.deshpande@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Kushal Jain',
      email: 'kushal.jain@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Ritika Ghosh',
      email: 'ritika.ghosh@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Aarohi Banerjee',
      email: 'aarohi.banerjee@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Nikhil Rao',
      email: 'nikhil.rao@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Vanya Iyer',
      email: 'vanya.iyer@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Eshan Mallick',
      email: 'eshan.mallick@proxyproof.demo',
      role: DemoRole.student,
    ),
    DemoUser(
      name: 'Kavish Arora',
      email: 'kavish.arora@proxyproof.demo',
      role: DemoRole.student,
    ),
  ];

  static const classes = <DemoClass>[
    DemoClass(
      name: 'Computer Networks',
      room: 'B204',
      teacherEmail: 'alex.morgan@proxyproof.demo',
    ),
    DemoClass(
      name: 'Data Structures',
      room: 'B204',
      teacherEmail: 'alex.morgan@proxyproof.demo',
    ),
    DemoClass(
      name: 'Operating Systems',
      room: 'C112',
      teacherEmail: 'priya.shah@proxyproof.demo',
    ),
  ];

  static const sessions = <DemoSession>[
    DemoSession(
      className: 'Computer Networks',
      startedAt: 'Today · 09:00 AM',
      presentCount: 5,
      enrolledCount: 12,
    ),
    DemoSession(
      className: 'Data Structures',
      startedAt: 'Yesterday · 11:30 AM',
      presentCount: 11,
      enrolledCount: 12,
    ),
    DemoSession(
      className: 'Operating Systems',
      startedAt: 'Monday · 02:00 PM',
      presentCount: 10,
      enrolledCount: 12,
    ),
  ];
}
