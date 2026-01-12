import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduerp_app/shared/widgets/placeholder_screen.dart';
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
import '../../features/events/presentation/events_dashboard_screen.dart';
import '../../features/events/presentation/event_list_screen.dart';
import '../../features/exams/presentation/exams_dashboard_screen.dart';

import '../../features/assignments/presentation/assignments_dashboard_screen.dart';
import '../../features/students/presentation/student_dashboard_screen.dart';
import '../../features/hostel/presentation/hostel_screen.dart';
import '../../features/hostel/presentation/hostel_dashboard_screen.dart';
import '../../features/admission/presentation/admission_dashboard_screen.dart';
import '../../features/admission/presentation/admission_list_screen.dart';
import '../../features/academics/presentation/class_list_screen.dart';
import '../../features/academics/presentation/section_list_screen.dart';
import '../../features/academics/presentation/subject_list_screen.dart';
import '../../features/academics/presentation/academic_year_list_screen.dart';
import '../../features/academics/presentation/academic_year_form_screen.dart';
import '../../features/academics/presentation/term_list_screen.dart';
import '../../features/academics/presentation/term_form_screen.dart';
import '../../features/academics/presentation/stream_list_screen.dart';
import '../../features/academics/presentation/stream_form_screen.dart';
import '../../features/academics/presentation/class_subject_list_screen.dart';
import '../../features/academics/presentation/class_subject_form_screen.dart';
import '../../features/academics/presentation/class_form_screen.dart';
import '../../features/academics/presentation/section_form_screen.dart';
import '../../features/academics/presentation/holiday_form_screen.dart';
import '../../features/academics/presentation/timetable_screen.dart';
import '../../features/academics/presentation/subject_form_screen.dart';
import '../../features/academics/presentation/holiday_list_screen.dart';
import '../../features/academics/presentation/house_list_screen.dart';
import '../../features/academics/presentation/house_form_screen.dart';
import '../../features/academics/presentation/grading_system_list_screen.dart';
import '../../features/academics/presentation/grading_system_form_screen.dart';
import '../../features/academics/presentation/grade_list_screen.dart';
import '../../features/academics/presentation/syllabus_list_screen.dart';
import '../../features/academics/presentation/syllabus_form_screen.dart';
import '../../features/academics/presentation/study_material_list_screen.dart';
import '../../features/academics/presentation/study_material_form_screen.dart';
import '../../features/reports/presentation/report_selection_screen.dart';
import '../../features/users/presentation/user_list_screen.dart';
import '../../shared/widgets/main_scaffold.dart';


final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
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
      
      // SHELL ROUTE FOR PERSISTENT BOTTOM NAVIGATION
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),

          // Students Module
          GoRoute(
            path: '/students',
            builder: (context, state) => const StudentDashboardScreen(),
            routes: [
               GoRoute(
                path: 'list',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const StudentListScreen(),
              ),
              GoRoute(
                path: 'add',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const StudentWrapperFormScreen(),
              ),
              GoRoute(
                path: 'detail',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                   final student = state.extra as Student; 
                   return StudentDetailScreen(student: student);
                },
              ),
              GoRoute(
                path: 'onboarding/:id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return StudentOnboardingScreen(studentId: id);
                },
              ),
              GoRoute(
                path: ':id/documents',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return StudentDocumentUploadScreen(studentId: id);
                },
              ),
            ],
          ),

          // Academics Module
          GoRoute(
            path: '/academics',
            builder: (context, state) => const AcademicsDashboardScreen(),
            routes: [
               // Core Setup
               GoRoute(
                 path: 'academic-years',
                 builder: (context, state) => const AcademicYearListScreen(),
                 routes: [
                    GoRoute(
                      path: 'create',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) => const AcademicYearFormScreen(),
                    ),
                    GoRoute(
                      path: ':id/edit',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return AcademicYearFormScreen(id: id);
                      },
                    ),
                 ],
               ),
               // Terms
               GoRoute(
                 path: 'terms',
                 builder: (context, state) => const TermListScreen(),
                 routes: [
                    GoRoute(
                      path: 'create',
                       parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) => const TermFormScreen(),
                    ),
                    GoRoute(
                      path: ':id/edit',
                       parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return TermFormScreen(id: id);
                      },
                    ),
                 ],
               ),
               // Streams
               GoRoute(
                 path: 'streams',
                 builder: (context, state) => const StreamListScreen(),
                 routes: [
                    GoRoute(
                      path: 'create',
                       parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) => const StreamFormScreen(),
                    ),
                    GoRoute(
                      path: ':id/edit',
                       parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return StreamFormScreen(id: id);
                      },
                    ),
                 ],
               ),
               
               // Class Management
               GoRoute(
                path: 'classes',
                builder: (context, state) => const ClassListScreen(),
                routes: [
                   GoRoute(
                     path: 'create',
                      parentNavigatorKey: rootNavigatorKey,
                     builder: (context, state) => const ClassFormScreen(),
                   ),
                   GoRoute(
                     path: ':id/edit',
                      parentNavigatorKey: rootNavigatorKey,
                     builder: (context, state) {
                       final id = state.pathParameters['id']!;
                       return ClassFormScreen(id: id);
                     },
                   ),
                ],
              ),
               GoRoute(
                path: 'sections',
                builder: (context, state) => const SectionListScreen(),
                routes: [
                   GoRoute(
                     path: 'create',
                      parentNavigatorKey: rootNavigatorKey,
                     builder: (context, state) => const SectionFormScreen(),
                   ),
                   GoRoute(
                     path: ':id/edit',
                      parentNavigatorKey: rootNavigatorKey,
                     builder: (context, state) {
                       final id = state.pathParameters['id']!;
                       return SectionFormScreen(id: id);
                     },
                   ),
                ],
               ),
               // Subjects
               GoRoute(
                 path: 'subjects',
                 builder: (context, state) => const SubjectListScreen(),
                 routes: [
                    GoRoute(
                      path: 'create',
                       parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) => const SubjectFormScreen(),
                    ),
                    GoRoute(
                      path: ':id/edit',
                       parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return SubjectFormScreen(id: id);
                      },
                    ),
                 ],
               ),
                // Class Subjects
                GoRoute(
                  path: 'class-subjects',
                  builder: (context, state) => const ClassSubjectListScreen(),
                  routes: [
                    GoRoute(
                      path: 'create',
                       parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) => const ClassSubjectFormScreen(),
                    ),
                    GoRoute(
                      path: ':id/edit',
                       parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return ClassSubjectFormScreen(id: id);
                      },
                    ),
                  ],
                ),
               
               // Timetable
               GoRoute(
                 path: 'timetable',
                 builder: (context, state) => const TimetableScreen(),
               ),
               
               
               // Attendance & Holidays
               GoRoute(path: 'attendance', builder: (context, state) => const AttendanceDashboardScreen()),
               GoRoute(
                 path: 'holidays',
                 builder: (context, state) => const HolidayListScreen(),
                 routes: [
                   GoRoute(
                     path: 'create',
                      parentNavigatorKey: rootNavigatorKey,
                     builder: (context, state) => const HolidayFormScreen(),
                   ),
                   GoRoute(
                     path: ':id/edit',
                      parentNavigatorKey: rootNavigatorKey,
                     builder: (context, state) {
                       final id = state.pathParameters['id']!;
                       return HolidayFormScreen(id: id);
                     },
                   ),
                 ],
               ),
               
               // Curriculum
               GoRoute(
            path: 'syllabus',
            builder: (context, state) => const SyllabusListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                 parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const SyllabusFormScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'study-materials',
            builder: (context, state) => const StudyMaterialListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                 parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const StudyMaterialFormScreen(),
              ),
            ],
          ),     // Others
               GoRoute(
                 path: 'houses',
                 builder: (context, state) => const HouseListScreen(),
                 routes: [
                   GoRoute(
                     path: 'add',
                      parentNavigatorKey: rootNavigatorKey,
                     builder: (context, state) => const HouseFormScreen(),
                   ),
                 ],
               ),
               GoRoute(
                 path: 'grading',
                 builder: (context, state) => const GradingSystemListScreen(),
                 routes: [
                   GoRoute(
                     path: 'add',
                      parentNavigatorKey: rootNavigatorKey,
                     builder: (context, state) => const GradingSystemFormScreen(),
                   ),
                   GoRoute(
                     path: ':id/grades',
                      parentNavigatorKey: rootNavigatorKey,
                     builder: (context, state) {
                       final id = state.pathParameters['id']!;
                       final name = state.extra as String? ?? 'Grading System'; // Get name from extra
                       return GradeListScreen(gradingSystemId: id, gradingSystemName: name);
                     },
                   ),
                 ],
               ),
            ],
          ),

          // HR Module
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

          // Finance Module
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

          // Other Modules
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
            builder: (context, state) => const AdmissionDashboardScreen(),
            routes: [
               GoRoute(
                path: 'list',
                builder: (context, state) => const AdmissionListScreen(),
              ),
            ],
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
            path: '/reports',
            builder: (context, state) => const ReportSelectionScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UserListScreen(),
          ),
        ],
      ),
    ],
  );
});
