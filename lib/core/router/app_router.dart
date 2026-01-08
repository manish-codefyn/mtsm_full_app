import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduerp_app/shared/widgets/placeholder_screen.dart'; // Import Placeholder
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/communications/presentation/communication_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/tenant/presentation/tenant_selection_screen.dart';
import '../../features/students/presentation/student_list_screen.dart';
import '../../features/students/presentation/student_form_screen.dart';
import '../../features/students/presentation/student_detail_screen.dart';
import '../../features/students/presentation/student_wrapper_form_screen.dart';
import '../../features/students/presentation/student_onboarding_screen.dart';
import '../../features/students/presentation/student_document_upload_screen.dart';
import '../../features/students/domain/student.dart';
import '../../features/academics/presentation/academics_dashboard_screen.dart';
import '../../features/hr/presentation/staff_list_screen.dart';
import '../../features/hr/presentation/staff_dashboard_screen.dart';
import '../../features/finance/presentation/finance_dashboard_screen.dart';
import '../../features/finance/presentation/fee_list_screen.dart';
import '../../features/finance/presentation/invoice_list_screen.dart';
import '../../features/attendance/presentation/screens/attendance_dashboard_screen.dart';
import '../../features/transport/presentation/transport_screen.dart';
import '../../features/transport/presentation/transport_dashboard_screen.dart';
import '../../features/transport/presentation/transport_dashboard_screen.dart';
import '../../features/events/presentation/events_dashboard_screen.dart';
import '../../features/events/presentation/event_list_screen.dart';
import '../../features/exams/presentation/exams_dashboard_screen.dart';

import '../../features/assignments/presentation/assignments_dashboard_screen.dart';
import '../../features/students/presentation/student_dashboard_screen.dart';
import '../../features/hostel/presentation/hostel_screen.dart';
import '../../features/hostel/presentation/hostel_dashboard_screen.dart';


final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/tenant',
    routes: [
      GoRoute(
        path: '/tenant',
        builder: (context, state) => const TenantSelectionScreen(),
      ),
      GoRoute(
        path: '/events',
        builder: (context, state) => const EventsDashboardScreen(),
        routes: [
          GoRoute(
            path: 'list',
            builder: (context, state) => const EventListScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),

      GoRoute(
        path: '/students',
        builder: (context, state) => const StudentDashboardScreen(),
        routes: [
           GoRoute(
            path: 'list',
            builder: (context, state) => const StudentListScreen(),
          ),
          GoRoute(
            path: 'add',
            builder: (context, state) => const StudentWrapperFormScreen(),
          ),
          GoRoute(
            path: 'detail',
            builder: (context, state) {
               // Expecting Student object in extra
               final student = state.extra as Student; 
               return StudentDetailScreen(student: student);
            },

          ),
          GoRoute(
            path: 'onboarding/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return StudentOnboardingScreen(studentId: id);
            },
          ),
          GoRoute(
            path: ':id/documents',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return StudentDocumentUploadScreen(studentId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/academics',
        builder: (context, state) => const AcademicsDashboardScreen(),
        routes: [
           GoRoute(path: 'classes', builder: (context, state) => const Scaffold(body: Center(child: Text('Classes List Coming Recently')))),
           GoRoute(path: 'sections', builder: (context, state) => const Scaffold(body: Center(child: Text('Sections List Coming Recently')))),
           GoRoute(path: 'subjects', builder: (context, state) => const Scaffold(body: Center(child: Text('Subjects List Coming Recently')))),
           GoRoute(path: 'timetable', builder: (context, state) => const Scaffold(body: Center(child: Text('Timetable Coming Recently')))),
        ],
      ),
      GoRoute(
        path: '/hr/staff',
        builder: (context, state) => const StaffDashboardScreen(),
        routes: [
           GoRoute(
            path: 'list',
            builder: (context, state) => const StaffListScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/finance',
        builder: (context, state) => const FinanceDashboardScreen(),
        routes: [
            GoRoute(
              path: 'fees',
              builder: (context, state) => const FeeListScreen(),
            ),
          GoRoute(
            path: 'my-invoices',
            builder: (context, state) => const InvoiceListScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/attendance',
        builder: (context, state) => const AttendanceDashboardScreen(),
      ),
      GoRoute(
        path: '/transport',
        builder: (context, state) => const TransportDashboardScreen(),
        routes: [
           GoRoute(
            path: 'list',
            builder: (context, state) => const TransportScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/hostel',
        builder: (context, state) => const HostelDashboardScreen(),
        routes: [
           GoRoute(
            path: 'list',
            builder: (context, state) => const HostelScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/exams',
        builder: (context, state) => const ExamsDashboardScreen(),
        routes: [
           GoRoute(
             path: 'schedule',
             builder: (context, state) => const Scaffold(body: Center(child: Text("Exam Schedule List - TODO"))), 
           )
        ]
      ),
      GoRoute(
        path: '/communications',
        builder: (context, state) => const CommunicationScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/assignments',
        builder: (context, state) => const AssignmentsDashboardScreen(),
      ),
      GoRoute(
        path: '/admission',
        builder: (context, state) => const PlaceholderScreen(title: 'Admission'),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const PlaceholderScreen(title: 'Analytics'),
      ),
      GoRoute(
        path: '/library',
        builder: (context, state) => const PlaceholderScreen(title: 'Library'),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const PlaceholderScreen(title: 'Inventory'),
      ),
      GoRoute(
        path: '/security',
        builder: (context, state) => const PlaceholderScreen(title: 'Security'),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const PlaceholderScreen(title: 'Users'),
      ),
    ],
  );
});
