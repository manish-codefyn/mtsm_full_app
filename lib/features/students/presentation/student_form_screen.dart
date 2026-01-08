import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/constants.dart';
import '../data/student_repository.dart';
import '../domain/student.dart';
import '../domain/guardian.dart';
import '../domain/student_address.dart';
import '../domain/student_medical_info.dart';
import '../domain/student_identification.dart';
import '../../academics/data/academics_repository.dart';
import 'forms/guardian_form.dart';
import 'forms/address_form.dart';
import 'forms/medical_form.dart';
import 'forms/identification_form.dart';
import 'forms/transport_form.dart';
import 'forms/hostel_form.dart';
import '../domain/student_transport.dart';
import '../domain/student_hostel.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  final Student? student; 
  const StudentFormScreen({super.key, this.student});

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>(); // For Basic Info
  
  // Basic Info Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _admissionNoController;
  late TextEditingController _emailController;
  late TextEditingController _institutionalEmailController;
  late TextEditingController _mobileController;
  late TextEditingController _mobileSecondaryController;
  late TextEditingController _nationalityController;
  late TextEditingController _placeOfBirthController;
  late TextEditingController _rollNoController;
  late TextEditingController _regNoController;
  late TextEditingController _annualIncomeController;
  late TextEditingController _scholarshipTypeController;
  late TextEditingController _currentSemesterController;
  late TextEditingController _creditsEarnedController;
  late TextEditingController _cgpaController;
  
  // Basic Info State
  String _gender = 'M';
  String _bloodGroup = 'A+';
  String _religion = 'HINDU';
  String _category = 'GENERAL';
  String _maritalStatus = 'SINGLE';
  String _admissionType = 'REGULAR';
  String _feeCategory = 'REGULAR';
  String _status = 'ACTIVE';
  bool _isMinority = false;
  bool _isPhysicallyChallenged = false;
  DateTime? _dob;
  DateTime? _enrollmentDate;
  
  // Academic Assignment
  String? _selectedClass;
  String? _selectedStream;
  String? _selectedSection;

  // New Sections Data
  List<Guardian> _guardians = [];
  List<StudentAddress> _addresses = [];
  StudentMedicalInfo? _medicalInfo;
  StudentIdentification? _identification;
  StudentTransport? _transport;
  StudentHostel? _hostel;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(currentAcademicYearProvider);
    });

    final s = widget.student;
    _firstNameController = TextEditingController(text: s?.firstName ?? '');
    _middleNameController = TextEditingController(text: s?.middleName ?? '');
    _lastNameController = TextEditingController(text: s?.lastName ?? '');
    _admissionNoController = TextEditingController(text: s?.admissionNumber ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');
    _institutionalEmailController = TextEditingController(text: s?.institutionalEmail ?? '');
    _mobileController = TextEditingController(text: s?.mobilePrimary ?? '');
    _mobileSecondaryController = TextEditingController(text: s?.mobileSecondary ?? '');
    _nationalityController = TextEditingController(text: s?.nationality ?? 'Indian');
    _placeOfBirthController = TextEditingController(text: s?.placeOfBirth ?? '');
    _rollNoController = TextEditingController(text: s?.rollNumber ?? '');
    _regNoController = TextEditingController(text: s?.regNo ?? '');
    _annualIncomeController = TextEditingController(text: s?.annualFamilyIncome?.toString() ?? '');
    _scholarshipTypeController = TextEditingController(text: s?.scholarshipType ?? '');
    _currentSemesterController = TextEditingController(text: s?.currentSemester?.toString() ?? '1');
    _creditsEarnedController = TextEditingController(text: s?.totalCreditsEarned?.toString() ?? '0');
    _cgpaController = TextEditingController(text: s?.cumulativeGradePoint?.toString() ?? '0');

    if (s != null) {
       _gender = s.gender ?? 'M';
       _bloodGroup = s.bloodGroup ?? 'A+';
       _religion = s.religion ?? 'HINDU';
       _category = s.category ?? 'GENERAL';
       _maritalStatus = s.maritalStatus ?? 'SINGLE';
       _admissionType = s.admissionType ?? 'REGULAR';
       _feeCategory = s.feeCategory ?? 'REGULAR';
       _status = s.status ?? 'ACTIVE';
       _isMinority = s.isMinority ?? false;
       _isPhysicallyChallenged = s.isPhysicallyChallenged ?? false;
       _selectedClass = s.currentClass;
       _selectedStream = s.stream;
       _selectedSection = s.section;
       if (s.dateOfBirth != null) _dob = DateTime.tryParse(s.dateOfBirth!);
       if (s.enrollmentDate != null) _enrollmentDate = DateTime.tryParse(s.enrollmentDate!);
    } else {
       // Initialize at least one empty guardian and address for new forms
       if (_guardians.isEmpty) {
         _guardians.add(Guardian(student: '', relation: 'FATHER', fullName: '', phonePrimary: '', isPrimary: true));
       }
       if (_addresses.isEmpty) {
         _addresses.add(StudentAddress(student: '', addressLine1: '', city: '', state: '', pincode: '', isCurrent: true));
       }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _admissionNoController.dispose();
    _emailController.dispose();
    _institutionalEmailController.dispose();
    _mobileController.dispose();
    _mobileSecondaryController.dispose();
    _nationalityController.dispose();
    _placeOfBirthController.dispose();
    _rollNoController.dispose();
    _regNoController.dispose();
    _annualIncomeController.dispose();
    _scholarshipTypeController.dispose();
    _currentSemesterController.dispose();
    _creditsEarnedController.dispose();
    _cgpaController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    // Validate Basic Info
    if (!_formKey.currentState!.validate()) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fix errors in Basic Info tab')));
       return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(studentRepositoryProvider);
      final currentYear = await ref.read(currentAcademicYearProvider.future);
      
      if (currentYear == null) throw Exception('No active academic year found.');

      final dobValue = _dob?.toIso8601String().split('T')[0];
      final enrollValue = _enrollmentDate?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0];

      // Nested Data Preparation
      final guardianData = _guardians.map((g) => g.toJson()..remove('id')..remove('student')).toList();
      final addressData = _addresses.map((a) => a.toJson()..remove('id')..remove('student')).toList();
      
      Map<String, dynamic>? medicalData;
      if (_medicalInfo != null) {
        medicalData = _medicalInfo!.toJson();
        medicalData.remove('id');
        medicalData.remove('student');
      }

      Map<String, dynamic>? identificationData;
      if (_identification != null) {
        identificationData = _identification!.toJson();
        identificationData.remove('id');
        identificationData.remove('student');
      }

      // Construct Payload
      final studentData = {
        'first_name': _firstNameController.text,
        'middle_name': _middleNameController.text,
        'last_name': _lastNameController.text,
        'admission_number': _admissionNoController.text,
        'roll_number': _rollNoController.text,
        'reg_no': _regNoController.text,
        'personal_email': _emailController.text,
        'institutional_email': _institutionalEmailController.text,
        'mobile_primary': _mobileController.text,
        'mobile_secondary': _mobileSecondaryController.text,
        'gender': _gender,
        'date_of_birth': dobValue,
        'place_of_birth': _placeOfBirthController.text,
        'blood_group': _bloodGroup,
        'religion': _religion,
        'category': _category,
        'marital_status': _maritalStatus,
        'nationality': _nationalityController.text,
        'is_minority': _isMinority,
        'is_physically_challenged': _isPhysicallyChallenged,
        'annual_family_income': _annualIncomeController.text.isNotEmpty 
            ? double.tryParse(_annualIncomeController.text) 
            : null,
        'academic_year': currentYear.id,
        'current_class': _selectedClass,
        'stream': _selectedStream,
        'section': _selectedSection,
        'admission_type': _admissionType,
        'enrollment_date': enrollValue,
        'fee_category': _feeCategory,
        'scholarship_type': _scholarshipTypeController.text,
        'current_semester': _currentSemesterController.text.isNotEmpty
            ? int.tryParse(_currentSemesterController.text) ?? 1
            : 1,
        'total_credits_earned': _creditsEarnedController.text.isNotEmpty
            ? double.tryParse(_creditsEarnedController.text) ?? 0.0
            : 0.0,
        'cumulative_grade_point': _cgpaController.text.isNotEmpty
            ? double.tryParse(_cgpaController.text) ?? 0.0
            : 0.0,
        'status': _status,
        
        'guardians': guardianData,
        'addresses': addressData,
        'medical_info': medicalData,
        'identification': identificationData,
      };
      
      print('DEBUG: Student Payload: $studentData');

      String studentId;
      if (widget.student != null && widget.student!.id != null) {
        await repo.updateStudent(widget.student!.id!, studentData);
        studentId = widget.student!.id!;
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student updated successfully')));
      } else {
        studentId = await repo.createStudent(studentData);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student created successfully')));
      }
      
      if (mounted) {
        if (widget.student != null && widget.student!.id != null) {
          // If editing, go back to student list
          context.go('/students');
        } else {
          // If creating new student, go to onboarding
          context.go('/students/onboarding/$studentId');
        }
      }

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;
    
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Student' : 'Add Student'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Basic Info'),
              Tab(text: 'Guardians'),
              Tab(text: 'Addresses'),
              Tab(text: 'Medical'),
              Tab(text: 'Identification'),
              Tab(text: 'Transport'),
              Tab(text: 'Hostel'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveStudent,
            )
          ],
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : TabBarView(
            children: [
              _buildBasicInfoTab(),
              _buildGuardiansTab(),
              _buildAddressesTab(),
              _buildMedicalTab(),
              _buildIdentificationTab(),
              _buildTransportTab(),
              _buildHostelTab(),
            ],
          ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION: PERSONAL INFORMATION
            Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800])),
            const SizedBox(height: 12),
            
            // NAME
            Row(children: [
              Expanded(child: TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'First Name *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null)),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _middleNameController, decoration: const InputDecoration(labelText: 'Middle Name', border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Last Name *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null)),
            ]),
            const SizedBox(height: 16),
            
            // Gender, DOB, Place of Birth
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(value: _gender, items: ['M','F','O'].map((e)=>DropdownMenuItem(value: e, child: Text(e == 'M' ? 'Male' : e == 'F' ? 'Female' : 'Other'))).toList(), onChanged: (v)=>setState(()=>_gender=v!), decoration: const InputDecoration(labelText: 'Gender *', border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              Expanded(child: InkWell(
                onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: DateTime(2015), firstDate: DateTime(1990), lastDate: DateTime.now());
                  if(d!=null) setState(()=>_dob=d);
                },
                child: InputDecorator(decoration: const InputDecoration(labelText: 'Date of Birth *', border: OutlineInputBorder()), child: Text(_dob?.toLocal().toString().split(' ')[0] ?? 'Select')),
              )),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _placeOfBirthController, decoration: const InputDecoration(labelText: 'Place of Birth', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 16),
            
            // Blood Group, Marital Status, Nationality
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(value: _bloodGroup, items: ['A+','A-','B+','B-','AB+','AB-','O+','O-'].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v)=>setState(()=>_bloodGroup=v!), decoration: const InputDecoration(labelText: 'Blood Group', border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              Expanded(child: DropdownButtonFormField<String>(
                value: _maritalStatus, 
                items: ['SINGLE','MARRIED','DIVORCED','WIDOWED'].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(), 
                onChanged: (v)=>setState(()=>_maritalStatus=v!), 
                decoration: const InputDecoration(labelText: 'Marital Status', border: OutlineInputBorder())
              )),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _nationalityController, decoration: const InputDecoration(labelText: 'Nationality', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 24),
            
            // SECTION: CONTACT INFORMATION
            Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800])),
            const SizedBox(height: 12),
            
            Row(children: [
              Expanded(child: TextFormField(controller: _mobileController, decoration: const InputDecoration(labelText: 'Mobile Primary *', border: OutlineInputBorder()), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Required' : null)),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _mobileSecondaryController, decoration: const InputDecoration(labelText: 'Mobile Secondary', border: OutlineInputBorder()), keyboardType: TextInputType.phone)),
            ]),
            const SizedBox(height: 16),
            
            Row(children: [
              Expanded(child: TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Personal Email *', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress, validator: (v) => v!.contains('@') ? null : 'Invalid')),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(
                controller: _institutionalEmailController, 
                decoration: InputDecoration(
                  labelText: 'Institutional Email', 
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[100],
                  helperText: 'Auto-generated if empty'
                ), 
                keyboardType: TextInputType.emailAddress
              )),
            ]),
            const SizedBox(height: 24),
            
            // SECTION: IDENTIFICATION NUMBERS
            Text('Identification Numbers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800])),
            const SizedBox(height: 12),
            
            Row(children: [
              Expanded(child: TextFormField(controller: _admissionNoController, decoration: const InputDecoration(labelText: 'Admission No *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null)),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _rollNoController, decoration: const InputDecoration(labelText: 'Roll No', border: OutlineInputBorder(), helperText: 'Auto-generated if empty'))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(
                controller: _regNoController, 
                decoration: InputDecoration(
                  labelText: 'Registration No', 
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[100],
                  helperText: 'Auto-generated if empty'
                )
              )),
            ]),
            const SizedBox(height: 24),
            
            // SECTION: ACADEMIC ASSIGNMENT
            Text('Academic Assignment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800])),
            const SizedBox(height: 12),
            
            Row(children: [
              Expanded(child: InkWell(
                onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 30)));
                  if(d!=null) setState(()=>_enrollmentDate=d);
                },
                child: InputDecorator(decoration: const InputDecoration(labelText: 'Enrollment Date', border: OutlineInputBorder()), child: Text(_enrollmentDate?.toLocal().toString().split(' ')[0] ?? 'Select')),
              )),
              const SizedBox(width: 8),
              Expanded(child: DropdownButtonFormField<String>(
                value: _admissionType,
                items: ['REGULAR','TRANSFER','LATERAL','DIPLOMA','QUOTA','MANAGEMENT'].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v)=>setState(()=>_admissionType=v!),
                decoration: const InputDecoration(labelText: 'Admission Type', border: OutlineInputBorder())
              )),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(
                controller: _currentSemesterController, 
                decoration: const InputDecoration(labelText: 'Current Semester', border: OutlineInputBorder(), helperText: 'Default: 1'),
                keyboardType: TextInputType.number
              )),
            ]),
            const SizedBox(height: 16),
            
            Text('Note: Class, Stream, and Section will be assigned during onboarding', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic)),
            const SizedBox(height: 24),
            
            // SECTION: SOCIO-ECONOMIC INFORMATION
            Text('Socio-Economic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800])),
            const SizedBox(height: 12),
            
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                value: _religion, 
                items: ['HINDU','MUSLIM','CHRISTIAN','SIKH','BUDDHIST','JAIN','OTHER'].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(), 
                onChanged: (v)=>setState(()=>_religion=v!), 
                decoration: const InputDecoration(labelText: 'Religion', border: OutlineInputBorder())
              )),
              const SizedBox(width: 8),
              Expanded(child: DropdownButtonFormField<String>(
                value: _category, 
                items: ['GENERAL','SC','ST','OBC','EWS'].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(), 
                onChanged: (v)=>setState(()=>_category=v!), 
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder())
              )),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(
                controller: _annualIncomeController, 
                decoration: const InputDecoration(labelText: 'Annual Family Income', border: OutlineInputBorder(), prefixText: '₹ '),
                keyboardType: TextInputType.number
              )),
            ]),
            const SizedBox(height: 16),
            
            Row(children: [
              Expanded(child: CheckboxListTile(
                title: const Text('Is Minority?'),
                value: _isMinority,
                onChanged: (v) => setState(() => _isMinority = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              )),
              Expanded(child: CheckboxListTile(
                title: const Text('Is Physically Challenged?'),
                value: _isPhysicallyChallenged,
                onChanged: (v) => setState(() => _isPhysicallyChallenged = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              )),
            ]),
            const SizedBox(height: 24),
            
            // SECTION: FEE & FINANCIAL
            Text('Fee & Financial Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800])),
            const SizedBox(height: 12),
            
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                value: _feeCategory,
                items: ['REGULAR','CONCESSION','SCHOLARSHIP','FREE'].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v)=>setState(()=>_feeCategory=v!),
                decoration: const InputDecoration(labelText: 'Fee Category', border: OutlineInputBorder())
              )),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(
                controller: _scholarshipTypeController, 
                decoration: const InputDecoration(labelText: 'Scholarship Type', border: OutlineInputBorder(), helperText: 'e.g., Merit, Sports'),
              )),
            ]),
            const SizedBox(height: 24),
            
            // SECTION: ACADEMIC PERFORMANCE
            Text('Academic Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800])),
            const SizedBox(height: 12),
            
            Row(children: [
              Expanded(child: TextFormField(
                controller: _creditsEarnedController, 
                decoration: const InputDecoration(labelText: 'Total Credits Earned', border: OutlineInputBorder(), helperText: 'For higher education'),
                keyboardType: TextInputType.number
              )),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(
                controller: _cgpaController, 
                decoration: const InputDecoration(labelText: 'CGPA', border: OutlineInputBorder(), helperText: 'Cumulative Grade Point'),
                keyboardType: TextInputType.number
              )),
            ]),
            const SizedBox(height: 24),
            
            // SECTION: STATUS
            Text('Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800])),
            const SizedBox(height: 12),
            
            DropdownButtonFormField<String>(
              value: _status,
              items: ['INCOMPLETE','ACTIVE','INACTIVE','ALUMNI','SUSPENDED','WITHDRAWN','GRADUATED','TRANSFERRED'].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v)=>setState(()=>_status=v!),
              decoration: const InputDecoration(labelText: 'Student Status', border: OutlineInputBorder())
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGuardiansTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._guardians.asMap().entries.map((entry) {
          int idx = entry.key;
          return GuardianForm(
            index: idx,
            onSaved: (g) => setState(() => _guardians[idx] = g),
            onRemove: () => setState(() => _guardians.removeAt(idx)),
          );
        }).toList(),
        ElevatedButton.icon(
          onPressed: () => setState(() => _guardians.add(Guardian(student: '', relation: 'FATHER', fullName: '', phonePrimary: ''))),
          icon: const Icon(Icons.add),
          label: const Text('Add Guardian'),
        ),
      ],
    );
  }

  Widget _buildAddressesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
         ..._addresses.asMap().entries.map((entry) {
          int idx = entry.key;
          return AddressForm(
            index: idx,
            onSaved: (a) => setState(() => _addresses[idx] = a),
            onRemove: () => setState(() => _addresses.removeAt(idx)),
          );
        }).toList(),
        ElevatedButton.icon(
          onPressed: () => setState(() => _addresses.add(StudentAddress(student: '', addressLine1: '', city: '', state: '', pincode: ''))),
          icon: const Icon(Icons.add),
          label: const Text('Add Address'),
        ),
      ],
    );
  }

  Widget _buildMedicalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: MedicalInfoForm(onSaved: (m) => setState(() => _medicalInfo = m)),
    );
  }

  Widget _buildIdentificationTab() {
     return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: IdentificationForm(onSaved: (i) => setState(() => _identification = i)),
    );
  }

  Widget _buildTransportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: TransportForm(onSaved: (t) => setState(() => _transport = t)),
    );
  }

  Widget _buildHostelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: HostelForm(onSaved: (h) => setState(() => _hostel = h)),
    );
  }
}
