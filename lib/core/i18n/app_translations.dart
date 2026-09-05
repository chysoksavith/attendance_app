import 'package:flutter/material.dart';

class AppTranslations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General & Common
      'home': 'Home',
      'attendance': 'Attendance',
      'leave': 'Leave',
      'profile': 'Profile',
      'welcome_back': 'Welcome back',
      'welcome': 'Welcome',
      'view_all': 'View all',
      'see_all': 'See All',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'completed': 'Completed',

      // Home & Summary
      'todays_summary': "Today's Summary",
      'clock_in': 'Clock In',
      'clock_out': 'Clock Out',
      'clock_in_now': 'Clock In Now',
      'clock_out_now': 'Clock Out Now',
      'not_clocked_in': 'Not clocked in',
      'clocked_in': 'Clocked in',
      'clocked_out': 'Clocked out',
      'request_status': 'Request Status',
      'request': 'Request',
      'approved': 'Approved',
      'decline': 'Decline',
      'recent_activity': 'Recent Activity',
      'no_activity': 'No recent activity yet',

      // Attendance Screen
      'shift_completed': 'Today\'s attendance is completed',
      'shift_completed_desc': 'Shift completed for today',
      'currently_clocked_in': 'You are currently clocked in',
      'ready_to_record': 'Ready to record attendance',
      'tap_to_clock_in': 'Tap to clock in',
      'tap_to_clock_out': 'Tap to clock out',
      'all_done_today': 'All done for today',
      'total_hours': 'Total Hours',
      'recent_logs': 'Recent Logs',
      'no_logs': 'No attendance records yet',
      'confirm_clock_in': 'Are you sure you want to clock in now?',
      'confirm_clock_out': 'Are you sure you want to clock out for today?',
      'locked': 'Locked',
      'wait_seconds': 'Wait {seconds}s',
      'cooldown_active': 'Locked for 1 min to prevent accidental click',
      'cooldown_warning': 'Please wait {seconds}s before clocking out.',

      // Leave Management
      'manage_leave_requests': 'Manage your leave requests',
      'leave_balances': 'Leave Balances',
      'annual_leave': 'Annual',
      'sick_leave': 'Sick',
      'personal_leave': 'Personal',
      'recent_requests': 'Recent Requests',
      'no_leave_requests': 'No leave requests yet',
      'no_leave_balances': 'No leave balances found',
      'remaining': 'Remaining',
      'entitled': 'Entitled',
      'used': 'Used',
      'pending': 'Pending',
      'new_request': 'New Request',
      'apply_leave': 'Apply Leave',
      'leave_type': 'Leave Type',
      'start_date': 'Start Date',
      'end_date': 'End Date',
      'reason': 'Reason',
      'reason_hint': 'Explain the reason for leave...',
      'submit_request': 'Submit Request',
      'status': 'Status',
      'approved_status': 'Approved',
      'pending_status': 'Pending',
      'rejected': 'Rejected',
      'days': 'days',

      // Profile & Settings
      'personal_info': 'Personal Information',
      'employment': 'Employment Details',
      'attendance_history': 'Attendance History',
      'language': 'Language',
      'appearance': 'Appearance',
      'sign_out': 'Sign Out',
      'sign_out_confirm': 'Are you sure you want to sign out?',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'theme_system': 'System Default',
      'select_language': 'Select Language',
      'select_appearance': 'Select Appearance',
    },
    'km': {
      // General & Common
      'home': 'ទំព័រដើម',
      'attendance': 'វត្តមាន',
      'leave': 'ច្បាប់ឈប់សម្រាក',
      'profile': 'គណនី',
      'welcome_back': 'សូមស្វាគមន៍មកវិញ',
      'welcome': 'សូមស្វាគមន៍',
      'view_all': 'មើលទាំងអស់',
      'see_all': 'មើលទាំងអស់',
      'cancel': 'បោះបង់',
      'confirm': 'យល់ព្រម',
      'save': 'រក្សាទុក',
      'completed': 'បានបញ្ចប់',

      // Home & Summary
      'todays_summary': 'សង្ខេបថ្ងៃនេះ',
      'clock_in': 'ចូលធ្វើការ',
      'clock_out': 'ចេញធ្វើការ',
      'clock_in_now': 'កត់ត្រាចូលឥឡូវនេះ',
      'clock_out_now': 'កត់ត្រាចេញឥឡូវនេះ',
      'not_clocked_in': 'មិនទាន់កត់ត្រាចូល',
      'clocked_in': 'បានកត់ត្រាចូល',
      'clocked_out': 'បានកត់ត្រាចេញ',
      'request_status': 'ស្ថានភាពសំណើ',
      'request': 'សំណើ',
      'approved': 'បានអនុម័ត',
      'decline': 'បដិសេធ',
      'recent_activity': 'សកម្មភាពថ្មីៗ',
      'no_activity': 'មិនទាន់មានសកម្មភាពនៅឡើយទេ',

      // Attendance Screen
      'shift_completed': 'វត្តមានថ្ងៃនេះត្រូវបានបញ្ចប់',
      'shift_completed_desc': 'បានបញ្ចប់វត្តមានសម្រាប់ថ្ងៃនេះ',
      'currently_clocked_in': 'អ្នកកំពុងស្ថិតក្នុងម៉ោងធ្វើការ',
      'ready_to_record': 'ត្រៀមខ្លួនសម្រាប់កត់ត្រាវត្តមាន',
      'tap_to_clock_in': 'ចុចដើម្បីកត់ត្រាចូល',
      'tap_to_clock_out': 'ចុចដើម្បីកត់ត្រាចេញ',
      'all_done_today': 'បានបញ្ចប់សម្រាប់ថ្ងៃនេះ',
      'total_hours': 'ម៉ោងសរុប',
      'recent_logs': 'កំណត់ត្រាថ្មីៗ',
      'no_logs': 'មិនទាន់មានកំណត់ត្រាវត្តមាននៅឡើយទេ',
      'confirm_clock_in': 'តើអ្នកប្រាកដជាចង់កត់ត្រាចូលឥឡូវនេះមែនទេ?',
      'confirm_clock_out': 'តើអ្នកប្រាកដជាចង់កត់ត្រាចេញសម្រាប់ថ្ងៃនេះមែនទេ?',
      'locked': 'បានចាក់សោ',
      'wait_seconds': 'រង់ចាំ {seconds}វិ',
      'cooldown_active': 'បានចាក់សោ ១ នាទីដើម្បីការពារការចុចច្រឡំ',
      'cooldown_warning': 'សូមរង់ចាំ {seconds} វិនាទី មុននឹងកត់ត្រាចេញ។',

      // Leave Management
      'manage_leave_requests': 'គ្រប់គ្រងសំណើសុំច្បាប់របស់អ្នក',
      'leave_balances': 'សមតុល្យច្បាប់',
      'annual_leave': 'ប្រចាំឆ្នាំ',
      'sick_leave': 'ឈឺ',
      'personal_leave': 'ផ្ទាល់ខ្លួន',
      'recent_requests': 'សំណើថ្មីៗ',
      'no_leave_requests': 'មិនទាន់មានសំណើសុំច្បាប់នៅឡើយទេ',
      'no_leave_balances': 'មិនមានសមតុល្យច្បាប់នៅឡើយទេ',
      'remaining': 'នៅសល់',
      'entitled': 'សរុប',
      'used': 'បានប្រើ',
      'pending': 'កំពុងរង់ចាំ',
      'new_request': 'សំណើថ្មី',
      'apply_leave': 'ស្នើសុំច្បាប់',
      'leave_type': 'ប្រភេទច្បាប់',
      'start_date': 'កាលបរិច្ឆេទចាប់ផ្តើម',
      'end_date': 'កាលបរិច្ឆេទបញ្ចប់',
      'reason': 'មូលហេតុ',
      'reason_hint': 'បញ្ជាក់អំពីមូលហេតុនៃការសុំច្បាប់...',
      'submit_request': 'ដាក់ស្នើសំណើ',
      'status': 'ស្ថានភាព',
      'approved_status': 'បានអនុម័ត',
      'pending_status': 'កំពុងរង់ចាំ',
      'rejected': 'បដិសេធ',
      'days': 'ថ្ងៃ',

      // Profile & Settings
      'personal_info': 'ព័ត៌មានផ្ទាល់ខ្លួន',
      'employment': 'ព័ត៌មានការងារ',
      'attendance_history': 'ប្រវត្តវត្តមាន',
      'language': 'ភាសា',
      'appearance': 'រូបរាង / ស្បែក',
      'sign_out': 'ចាកចេញពីគណនី',
      'sign_out_confirm': 'តើអ្នកប្រាកដជាចង់ចាកចេញពីគណនីមែនទេ?',
      'theme_light': 'ពន្លឺ (Light)',
      'theme_dark': 'ងងឹត (Dark)',
      'theme_system': 'តាមប្រព័ន្ធ (System)',
      'select_language': 'ជ្រើសរើសភាសា',
      'select_appearance': 'ជ្រើសរើសរូបរាង',
    },
  };

  static String text(
    BuildContext context,
    String key, [
    Map<String, String>? params,
  ]) {
    final locale = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
    var value =
        _localizedValues[locale]?[key] ?? _localizedValues['en']?[key] ?? key;

    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue);
      });
    }

    return value;
  }
}

extension AppTranslationsExtension on BuildContext {
  String tr(String key, [Map<String, String>? params]) =>
      AppTranslations.text(this, key, params);
}
