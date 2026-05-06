import 'package:flutter/widgets.dart';

class S {
  static String t(BuildContext context, String key) {
    final code = Localizations.localeOf(context).languageCode;
    final m = code == 'ar' ? _ar : _en;
    return (m[key] ?? _en[key]) ?? key;
  }

  static const Map<String, String> _en = {
    // App / Auth
    'app_title': 'Smart Tasks AI',
    'signin_title': 'Sign in',
    'welcome_line': 'Sign in to sync your tasks, or continue as guest.',
    'email': 'Email',
    'password': 'Password',
    'sign_in': 'Sign in',
    'create_account': 'Create account',
    'continue_guest': 'Continue as guest',
    'enter_email_pass': 'Enter email & password',
    'invalid_email': 'Invalid email format',
    'pass_min': 'Password must be at least 6 chars',
    'guest_local': 'Guest mode (local). Enable Anonymous in Firebase to sync tasks.',
    'toggle_lang': 'Language',
    'toggle_theme': 'Theme',

    // Settings
    'settings': 'Settings',
    'appearance': 'Appearance',
    'theme_system': 'System',
    'theme_light': 'Light',
    'theme_dark': 'Dark',
    'language': 'Language',
    'lang_system': 'System language',
    'lang_en': 'English',
    'lang_ar': 'Arabic',

    // Tasks screen
    'tasks_title': 'My Tasks',
    'filter_all': 'All',
    'filter_active': 'Active',
    'filter_done': 'Done',
    'search_hint': 'Search tasks…',
    'no_tasks': 'No tasks yet',
    'use_plus': 'Use the + button to add your first task.',
    'ai_chat': 'AI Chat',
    'clear_completed': 'Clear completed',
    'sign_out': 'Sign out',
    'please_sign_in': 'Please sign in to view your tasks.',
    'go_to_login': 'Go to login',
    'new_task': 'New task',

    // New task
    'hero_text': 'Turn your goal into a task quickly.\nType the title and save — or create it with AI.',
    'title_label': 'Title',
    'notes_optional': 'Notes (optional)',
    'notes_hint': 'Context, sub-steps, link…',
    'create_with_ai': 'Create with AI',
    'save_task': 'Save task',
    'save_success': 'Saved successfully',
    'save_failed': 'Failed to save',
    'priority': 'Priority',
    'low': 'Low',
    'normal': 'Normal',
    'high': 'High',
    'tag_optional': 'Tag (optional)',
    'tag_hint': 'Work, Study…',
    'due_optional': 'Due date (optional)',
    'no_due_date': 'No due date',
    'show_optional': 'Show optional details',
    'hide_optional': 'Hide optional details',
    'preset_study': 'Plan my study session',
    'preset_grocery': 'Weekly grocery list',
    'preset_clean': 'Clean workspace',

    // Labels for AI prompt
    'goal': 'Goal',
    'context': 'Context',
    'due': 'Due',
    'priority_label': 'Priority',
    'tag': 'Tag',

    // Chat
    'chat_title': 'Smart Tasks AI',
    'add_from_reply': 'Add tasks from last reply',
    'copy_last_reply': 'Copy last reply',
    'clear_chat': 'Clear chat',
    'type_message': 'Type a message…',
    'waiting_reply': 'Waiting for reply...',
    'copied': 'Copied.',
    'suggest_order': 'Suggest AI Order',
    'confirm_ai_order': 'Confirm AI Order',
    'ai_order_applied': 'AI order applied',
    'no_reply_to_convert': 'No assistant reply to convert.',
    'no_reply_to_copy': 'No assistant reply to copy.',
    'added_tasks_n': 'Added {n} task(s).',
    'mock_banner':
        'AI mock mode is active or API key is missing.\nUse --dart-define=OPENAI_API_KEY=sk-XXXX for real responses, or --dart-define=USE_MOCK_AI=true for local mock.',
  };

  static const Map<String, String> _ar = {
    // App / Auth
    'app_title': 'Smart Tasks AI',
    'signin_title': 'تسجيل الدخول',
    'welcome_line': 'سجّل دخولك لمزامنة المهام، أو أكمل كضيف.',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'sign_in': 'دخول',
    'create_account': 'إنشاء حساب',
    'continue_guest': 'المتابعة كضيف',
    'enter_email_pass': 'أدخل البريد وكلمة المرور',
    'invalid_email': 'صيغة البريد غير صحيحة',
    'pass_min': 'كلمة المرور 6 أحرف على الأقل',
    'guest_local': 'وضع الضيف (محلي). فعّل Anonymous في Firebase للمزامنة.',
    'toggle_lang': 'اللغة',
    'toggle_theme': 'الوضع',

    // Settings
    'settings': 'الإعدادات',
    'appearance': 'المظهر',
    'theme_system': 'يتبع النظام',
    'theme_light': 'فاتح',
    'theme_dark': 'داكن',
    'language': 'اللغة',
    'lang_system': 'لغة النظام',
    'lang_en': 'الإنجليزية',
    'lang_ar': 'العربية',

    // Tasks screen
    'tasks_title': 'مهامي',
    'filter_all': 'الكل',
    'filter_active': 'نشِطة',
    'filter_done': 'منجزة',
    'search_hint': 'ابحث في المهام…',
    'no_tasks': 'لا توجد مهام بعد',
    'use_plus': 'استخدم زر + لإضافة أول مهمة.',
    'ai_chat': 'دردشة الذكاء',
    'clear_completed': 'حذف المنجزة',
    'sign_out': 'تسجيل الخروج',
    'please_sign_in': 'الرجاء تسجيل الدخول لعرض مهامك.',
    'go_to_login': 'اذهب لتسجيل الدخول',
    'new_task': 'مهمة جديدة',

    // New task
    'hero_text': 'حوّل هدفك إلى مهمة بسرعة.\nاكتب العنوان واحفظ — أو أنشئها بالذكاء.',
    'title_label': 'العنوان',
    'notes_optional': 'ملاحظات (اختياري)',
    'notes_hint': 'سياق، خطوات فرعية، رابط…',
    'create_with_ai': 'إنشاء بالذكاء',
    'save_task': 'حفظ المهمة',
    'save_success': 'تم الحفظ بنجاح',
    'save_failed': 'فشل الحفظ',
    'priority': 'الأولوية',
    'low': 'منخفضة',
    'normal': 'عادية',
    'high': 'عالية',
    'tag_optional': 'وسم (اختياري)',
    'tag_hint': 'عمل، دراسة…',
    'due_optional': 'تاريخ الاستحقاق (اختياري)',
    'no_due_date': 'بدون تاريخ',
    'show_optional': 'إظهار التفاصيل الاختيارية',
    'hide_optional': 'إخفاء التفاصيل الاختيارية',
    'preset_study': 'تخطيط جلسة مذاكرة',
    'preset_grocery': 'قائمة تسوق أسبوعية',
    'preset_clean': 'تنظيف مساحة العمل',

    // Labels for AI prompt
    'goal': 'الهدف',
    'context': 'السياق',
    'due': 'الاستحقاق',
    'priority_label': 'الأولوية',
    'tag': 'الوسم',

    // Chat
    'chat_title': 'Smart Tasks AI',
    'add_from_reply': 'إضافة مهام من آخر رد',
    'copy_last_reply': 'نسخ آخر رد',
    'clear_chat': 'مسح المحادثة',
    'type_message': 'اكتب رسالة…',
    'waiting_reply': 'بانتظار الرد...',
    'copied': 'تم النسخ.',
    'suggest_order': 'اقتراح ترتيب الذكاء',
    'confirm_ai_order': 'تأكيد ترتيب الذكاء',
    'ai_order_applied': 'تم تطبيق ترتيب الذكاء',
    'no_reply_to_convert': 'لا يوجد رد للمساعدة لتحويله.',
    'no_reply_to_copy': 'لا يوجد رد للمساعدة لنسخه.',
    'added_tasks_n': 'تمت إضافة {n} مهمة.',
    'mock_banner':
        'وضع المحاكاة مفعّل أو مفتاح الـ API مفقود.\nاستخدم --dart-define=OPENAI_API_KEY=sk-XXXX للردود الحقيقية، أو --dart-define=USE_MOCK_AI=true للمحلي.',
  };
}
