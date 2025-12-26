import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/tenant/presentation/tenant_selection_screen.dart';
import '../../features/students/presentation/student_list_screen.dart';
import '../../features/students/presentation/student_form_screen.dart';
import '../../features/students/presentation/student_detail_screen.dart';
import '../../features/students/domain/student.dart';
import '../../features/academics/presentation/academics_screen.dart';
import '../../features/hr/presentation/staff_list_screen.dart';
import '../../features/finance/presentation/fee_list_screen.dart';
import '../../features/attendance/presentation/screens/attendance_dashboard_screen.dart';
import '../../features/transport/presentation/transport_screen.dart';
import '../../features/hostel/presentation/hostel_screen.dart';


final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/tenant',
    routes: [
      GoRoute(
        path: '/tenant',
        builder: (context, state) => const TenantSelectionScreen(),
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
        builder: (context, state) => const StudentListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const StudentFormScreen(),
          ),
          GoRoute(
            path: 'detail',
            builder: (context, state) {
               // Expecting Student object in extra
               final student = state.extra as Student; 
               return StudentDetailScreen(student: student);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/academics',
        builder: (context, state) => const AcademicsScreen(),
      ),
      GoRoute(
        path: '/hr/staff',
        builder: (context, state) => const StaffListScreen(),
      ),
      GoRoute(
        path: '/finance/fees',
        builder: (context, state) => const FeeListScreen(),
      ),
      GoRoute(
        path: '/attendance',
        builder: (context, state) => const AttendanceDashboardScreen(),
      ),
      GoRoute(
        path: '/transport',
        builder: (context, state) => const TransportScreen(),
      ),
      GoRoute(
        path: '/hostel',
        builder: (context, state) => const HostelScreen(),
      ),
    ],
  );
});
