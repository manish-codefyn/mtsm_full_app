import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/student.dart';
import '../../../core/utils/form_validators.dart';
import '../data/student_repository.dart';
import '../../academics/data/academics_repository.dart';

class StudentWrapperFormScreen extends ConsumerStatefulWidget {
  final Student? student;
  const StudentWrapperFormScreen({super.key, this.student});

  @override
  ConsumerState<StudentWrapperFormScreen> createState() => _StudentWrapperFormScreenState();
}

class _StudentWrapperFormScreenState extends ConsumerState<StudentWrapperFormScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // STEP 1: Personal Information Controllers
  final _firstNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _placeOfBirthCtrl = TextEditingController();
  final _nationalityCtrl = TextEditingController(text: 'Indian');
  
  String _gender = 'M';
  String _bloodGroup = 'A+';
  String _maritalStatus = 'SINGLE';
  DateTime? _dob;
  
  // STEP 2: Contact Information Controllers
  final _mobilePrimaryCtrl = TextEditingController();
  final _mobileSecondaryCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _institutionalEmailCtrl = TextEditingController();
  
  // STEP 3: Address Controllers
  final _addressLine1Ctrl = TextEditingController();
  final _addressLine2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'India');
  
  // STEP 4: Identification Controllers
  final _admissionCtrl = TextEditingController();
  final _rollNoCtrl = TextEditingController();
  final _regNoCtrl = TextEditingController();
  
  // STEP 5: Academic Details Controllers
  final _currentSemesterCtrl = TextEditingController(text: '1');
  String _admissionType = 'REGULAR';
  DateTime? _enrollmentDate;
  
  // STEP 6: Socio-Economic Controllers
  final _annualIncomeCtrl = TextEditingController();
  String _religion = 'HINDU';
  String _category = 'GENERAL';
  bool _isMinority = false;
  bool _isPhysicallyChallenged = false;
  
  // STEP 7: Financial Controllers
  String _feeCategory = 'REGULAR';
  final _scholarshipTypeCtrl = TextEditingController();
  
  // STEP 8: Academic Performance Controllers
  final _creditsEarnedCtrl = TextEditingController(text: '0');
  final _cgpaCtrl = TextEditingController(text: '0');
  String _status = 'ACTIVE';
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      final s = widget.student!;
      _firstNameCtrl.text = s.firstName;
      _middleNameCtrl.text = s.middleName ?? '';
      _lastNameCtrl.text = s.lastName;
      _placeOfBirthCtrl.text = s.placeOfBirth ?? '';
      _nationalityCtrl.text = s.nationality ?? 'Indian';
      _gender = s.gender ?? 'M';
      _bloodGroup = s.bloodGroup ?? 'A+';
      _maritalStatus = s.maritalStatus ?? 'SINGLE';
      if (s.dateOfBirth != null) _dob = DateTime.tryParse(s.dateOfBirth!);
      
      _mobilePrimaryCtrl.text = s.mobilePrimary ?? '';
      _mobileSecondaryCtrl.text = s.mobileSecondary ?? '';
      _emailCtrl.text = s.email ?? '';
      _institutionalEmailCtrl.text = s.institutionalEmail ?? '';
      
      _admissionCtrl.text = s.admissionNumber ?? '';
      _rollNoCtrl.text = s.rollNumber ?? '';
      _regNoCtrl.text = s.regNo ?? '';
      
      _currentSemesterCtrl.text = s.currentSemester?.toString() ?? '1';
      _admissionType = s.admissionType ?? 'REGULAR';
      if (s.enrollmentDate != null) _enrollmentDate = DateTime.tryParse(s.enrollmentDate!);
      
      _annualIncomeCtrl.text = s.annualFamilyIncome?.toString() ?? '';
      _religion = s.religion ?? 'HINDU';
      _category = s.category ?? 'GENERAL';
      _isMinority = s.isMinority ?? false;
      _isPhysicallyChallenged = s.isPhysicallyChallenged ?? false;
      
      _feeCategory = s.feeCategory ?? 'REGULAR';
      _scholarshipTypeCtrl.text = s.scholarshipType ?? '';
      
      _creditsEarnedCtrl.text = s.totalCreditsEarned?.toString() ?? '0';
      _cgpaCtrl.text = s.cumulativeGradePoint?.toString() ?? '0';
      _status = s.status ?? 'ACTIVE';
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _placeOfBirthCtrl.dispose();
    _nationalityCtrl.dispose();
    _mobilePrimaryCtrl.dispose();
    _mobileSecondaryCtrl.dispose();
    _emailCtrl.dispose();
    _institutionalEmailCtrl.dispose();
    _addressLine1Ctrl.dispose();
    _addressLine2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    _countryCtrl.dispose();
    _admissionCtrl.dispose();
    _rollNoCtrl.dispose();
    _regNoCtrl.dispose();
    _currentSemesterCtrl.dispose();
    _annualIncomeCtrl.dispose();
    _scholarshipTypeCtrl.dispose();
    _creditsEarnedCtrl.dispose();
    _cgpaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'New Admission' : 'Edit Student'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            onStepContinue: () {
              // Only validate required fields on final submit, allow navigation otherwise
              if (_currentStep < 7) {
                setState(() => _currentStep += 1);
              } else {
                // Final step - validate entire form before submit
                if (_formKey.currentState!.validate()) {
                  _submitForm();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                }
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              } else {
                Navigator.pop(context);
              }
            },
            onStepTapped: (step) {
              // Allow direct navigation to any step
              setState(() => _currentStep = step);
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(_currentStep == 7 ? 'SUBMIT' : 'NEXT', style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('BACK', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                  ],
                ),
              );
            },
            steps: [
              _buildPersonalStep(),
              _buildContactStep(),
              _buildAddressStep(),
              _buildIdentificationStep(),
              _buildAcademicStep(),
              _buildSocioEconomicStep(),
              _buildFinancialStep(),
              _buildPerformanceStep(),
            ],
          ),
        ),
    );
  }

  Step _buildPersonalStep() {
    return Step(
      title: const Text('Personal'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[800])),
          const SizedBox(height: 16),
          
          Row(children: [
            Expanded(child: TextFormField(
              controller: _firstNameCtrl,
              decoration: const InputDecoration(labelText: 'First Name *', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            )),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(
              controller: _middleNameCtrl,
              decoration: const InputDecoration(labelText: 'Middle Name', border: OutlineInputBorder()),
            )),
          ]),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _lastNameCtrl,
            decoration: const InputDecoration(labelText: 'Last Name *', border: OutlineInputBorder()),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          
          Row(children: [
            Expanded(child: DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'M', child: Text('Male')),
                DropdownMenuItem(value: 'F', child: Text('Female')),
                DropdownMenuItem(value: 'O', child: Text('Other')),
              ],
              onChanged: (v) => setState(() => _gender = v!),
            )),
            const SizedBox(width: 12),
            Expanded(child: InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2015),
                  firstDate: DateTime(1990),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _dob = d);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date of Birth', border: OutlineInputBorder()),
                child: Text(_dob?.toLocal().toString().split(' ')[0] ?? 'Select Date'),
              ),
            )),
          ]),
          const SizedBox(height: 16),
          
          Row(children: [
            Expanded(child: TextFormField(
              controller: _placeOfBirthCtrl,
              decoration: const InputDecoration(labelText: 'Place of Birth', border: OutlineInputBorder()),
            )),
            const SizedBox(width: 12),
            Expanded(child: DropdownButtonFormField<String>(
              value: _bloodGroup,
              decoration: const InputDecoration(labelText: 'Blood Group', border: OutlineInputBorder()),
              items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _bloodGroup = v!),
            )),
          ]),
          const SizedBox(height: 16),
          
          Row(children: [
            Expanded(child: DropdownButtonFormField<String>(
              value: _maritalStatus,
              decoration: const InputDecoration(labelText: 'Marital Status', border: OutlineInputBorder()),
              items: ['SINGLE', 'MARRIED', 'DIVORCED', 'WIDOWED']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _maritalStatus = v!),
            )),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(
              controller: _nationalityCtrl,
              decoration: const InputDecoration(labelText: 'Nationality', border: OutlineInputBorder()),
            )),
          ]),
        ],
      ),
    );
  }

  Step _buildContactStep() {
    return Step(
      title: const Text('Contact'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[800])),
          const SizedBox(height: 16),
          
          Row(children: [
            Expanded(child: TextFormField(
              controller: _mobilePrimaryCtrl,
              decoration: const InputDecoration(labelText: 'Mobile Primary *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            )),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(
              controller: _mobileSecondaryCtrl,
              decoration: const InputDecoration(labelText: 'Mobile Secondary', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
            )),
          ]),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Personal Email *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v!.contains('@') ? null : 'Invalid email',
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _institutionalEmailCtrl,
            decoration: InputDecoration(
              labelText: 'Institutional Email',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: Colors.grey[100],
              helperText: 'Auto-generated if empty',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Step _buildAddressStep() {
    return Step(
      title: const Text('Address'),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Permanent Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[800])),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _addressLine1Ctrl,
            decoration: const InputDecoration(labelText: 'Address Line 1 *', border: OutlineInputBorder()),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _addressLine2Ctrl,
            decoration: const InputDecoration(labelText: 'Address Line 2', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          
          Row(children: [
            Expanded(child: TextFormField(
              controller: _cityCtrl,
              decoration: const InputDecoration(labelText: 'City *', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            )),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(
              controller: _stateCtrl,
              decoration: const InputDecoration(labelText: 'State *', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            )),
          ]),
          const SizedBox(height: 16),
          
          Row(children: [
            Expanded(child: TextFormField(
              controller: _pincodeCtrl,
              decoration: const InputDecoration(labelText: 'Pincode *', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            )),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(
              controller: _countryCtrl,
              decoration: const InputDecoration(labelText: 'Country', border: OutlineInputBorder()),
            )),
          ]),
        ],
      ),
    );
  }

  Step _buildIdentificationStep() {
    return Step(
      title: const Text('ID'),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Identification Numbers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[800])),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _admissionCtrl,
            decoration: const InputDecoration(labelText: 'Admission Number *', border: OutlineInputBorder()),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          
          Row(children: [
            Expanded(child: TextFormField(
              controller: _rollNoCtrl,
              decoration: const InputDecoration(
                labelText: 'Roll Number',
                border: OutlineInputBorder(),
                helperText: 'Auto-generated if empty',
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(
              controller: _regNoCtrl,
              decoration: InputDecoration(
                labelText: 'Registration Number',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
                helperText: 'Auto-generated if empty',
              ),
            )),
          ]),
        ],
      ),
    );
  }

  Step _buildAcademicStep() {
    return Step(
      title: const Text('Academic'),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Academic Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[800])),
          const SizedBox(height: 16),
          
          Row(children: [
            Expanded(child: InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (d != null) setState(() => _enrollmentDate = d);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Enrollment Date', border: OutlineInputBorder()),
                child: Text(_enrollmentDate?.toLocal().toString().split(' ')[0] ?? 'Select Date'),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: DropdownButtonFormField<String>(
              value: _admissionType,
              decoration: const InputDecoration(labelText: 'Admission Type', border: OutlineInputBorder()),
              items: ['REGULAR', 'TRANSFER', 'LATERAL', 'DIPLOMA', 'QUOTA', 'MANAGEMENT']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _admissionType = v!),
            )),
          ]),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _currentSemesterCtrl,
            decoration: const InputDecoration(
              labelText: 'Current Semester',
              border: OutlineInputBorder(),
              helperText: 'Default: 1',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(child: Text('Class, Stream, and Section will be assigned during onboarding process.')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Step _buildSocioEconomicStep() {
    return Step(
      title: const Text('Socio-Eco'),
      isActive: _currentStep >= 4,
      state: _currentStep > 4 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Socio-Economic Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[800])),
          const SizedBox(height: 16),
          
          Row(children: [
            Expanded(child: DropdownButtonFormField<String>(
              value: _religion,
              decoration: const InputDecoration(labelText: 'Religion', border: OutlineInputBorder()),
              items: ['HINDU', 'MUSLIM', 'CHRISTIAN', 'SIKH', 'BUDDHIST', 'JAIN', 'OTHER']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _religion = v!),
            )),
            const SizedBox(width: 12),
            Expanded(child: DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: ['GENERAL', 'SC', 'ST', 'OBC', 'EWS']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            )),
          ]),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _annualIncomeCtrl,
            decoration: const InputDecoration(
              labelText: 'Annual Family Income',
              border: OutlineInputBorder(),
              prefixText: '₹ ',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          CheckboxListTile(
            title: const Text('Is Minority?'),
            value: _isMinority,
            onChanged: (v) => setState(() => _isMinority = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            title: const Text('Is Physically Challenged?'),
            value: _isPhysicallyChallenged,
            onChanged: (v) => setState(() => _isPhysicallyChallenged = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Step _buildFinancialStep() {
    return Step(
      title: const Text('Financial'),
      isActive: _currentStep >= 5,
      state: _currentStep > 5 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fee & Financial Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[800])),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _feeCategory,
            decoration: const InputDecoration(labelText: 'Fee Category', border: OutlineInputBorder()),
            items: ['REGULAR', 'CONCESSION', 'SCHOLARSHIP', 'FREE']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _feeCategory = v!),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _scholarshipTypeCtrl,
            decoration: const InputDecoration(
              labelText: 'Scholarship Type',
              border: OutlineInputBorder(),
              helperText: 'e.g., Merit, Sports, Financial Aid',
            ),
          ),
        ],
      ),
    );
  }

  Step _buildPerformanceStep() {
    return Step(
      title: const Text('Status'),
      isActive: _currentStep >= 6,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Academic Performance & Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[800])),
          const SizedBox(height: 16),
          
          Row(children: [
            Expanded(child: TextFormField(
              controller: _creditsEarnedCtrl,
              decoration: const InputDecoration(
                labelText: 'Total Credits Earned',
                border: OutlineInputBorder(),
                helperText: 'For higher education',
              ),
              keyboardType: TextInputType.number,
            )),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(
              controller: _cgpaCtrl,
              decoration: const InputDecoration(
                labelText: 'CGPA',
                border: OutlineInputBorder(),
                helperText: 'Cumulative Grade Point',
              ),
              keyboardType: TextInputType.number,
            )),
          ]),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Student Status', border: OutlineInputBorder()),
            items: ['INCOMPLETE', 'ACTIVE', 'INACTIVE', 'ALUMNI', 'SUSPENDED', 'WITHDRAWN', 'GRADUATED', 'TRANSFERRED']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _status = v!),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentYear = await ref.read(currentAcademicYearProvider.future);
      if (currentYear == null) {
        throw Exception('No active academic year found');
      }

      final data = {
        'first_name': _firstNameCtrl.text,
        'middle_name': _middleNameCtrl.text,
        'last_name': _lastNameCtrl.text,
        'gender': _gender,
        'date_of_birth': _dob?.toIso8601String().split('T')[0],
        'place_of_birth': _placeOfBirthCtrl.text,
        'blood_group': _bloodGroup,
        'marital_status': _maritalStatus,
        'nationality': _nationalityCtrl.text,
        
        'mobile_primary': _mobilePrimaryCtrl.text,
        'mobile_secondary': _mobileSecondaryCtrl.text,
        'personal_email': _emailCtrl.text,
        'institutional_email': _institutionalEmailCtrl.text,
        
        // Address data
        'addresses': [
          {
            'address_type': 'PERMANENT',
            'address_line1': _addressLine1Ctrl.text,
            'address_line2': _addressLine2Ctrl.text,
            'city': _cityCtrl.text,
            'state': _stateCtrl.text,
            'pincode': _pincodeCtrl.text,
            'country': _countryCtrl.text,
            'is_current': true,  // Required by backend validation
          }
        ],
        
        'admission_number': _admissionCtrl.text,
        'roll_number': _rollNoCtrl.text,
        'reg_no': _regNoCtrl.text,
        
        'enrollment_date': _enrollmentDate?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
        'admission_type': _admissionType,
        'current_semester': int.tryParse(_currentSemesterCtrl.text) ?? 1,
        'academic_year': currentYear.id,
        
        'religion': _religion,
        'category': _category,
        'annual_family_income': _annualIncomeCtrl.text.isNotEmpty ? double.tryParse(_annualIncomeCtrl.text) : null,
        'is_minority': _isMinority,
        'is_physically_challenged': _isPhysicallyChallenged,
        
        'fee_category': _feeCategory,
        'scholarship_type': _scholarshipTypeCtrl.text,
        
        'total_credits_earned': double.tryParse(_creditsEarnedCtrl.text) ?? 0.0,
        'cumulative_grade_point': double.tryParse(_cgpaCtrl.text) ?? 0.0,
        'status': _status,
      };

      if (widget.student != null && widget.student!.id != null) {
        await ref.read(studentRepositoryProvider).updateStudent(widget.student!.id!, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✓ Student updated successfully'), backgroundColor: Colors.green)
          );
          Navigator.pop(context);
          ref.invalidate(studentPaginationProvider); // Refresh the list
        }
      } else {
        final studentId = await ref.read(studentRepositoryProvider).createStudent(data);
        // Refresh the list
        ref.invalidate(studentPaginationProvider);

        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Student created successfully'), backgroundColor: Colors.green)
        );
        Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        // Parse error message to be more user-friendly
        String errorMessage = 'Failed to save student';
        
        if (e.toString().contains('addresses')) {
          errorMessage = 'Please fill all required address fields';
        } else if (e.toString().contains('admission_number')) {
          if (e.toString().contains('unique')) {
            errorMessage = 'Admission number already exists';
          } else {
            errorMessage = 'Admission number is required';
          }
        } else if (e.toString().contains('email')) {
          if (e.toString().contains('unique')) {
            errorMessage = 'This email is already registered to another student';
          } else {
            errorMessage = 'Please check email format';
          }
        } else if (e.toString().contains('mobile')) {
          errorMessage = 'Please check mobile number format';
        } else if (e.toString().contains('academic_year')) {
          errorMessage = 'No active academic year found';
        } else {
          // Show a simplified version of the error
          final errStr = e.toString();
          if (errStr.length > 100) {
            errorMessage = 'Error: ${errStr.substring(0, 100)}...';
          } else {
            errorMessage = 'Error: $errStr';
          }
        }
        // Refresh the list
        ref.invalidate(studentPaginationProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
