# ENMS - Enhanced Network Management System
## Architecture Documentation

### Overview
ENMS هو تطبيق Flutter لإدارة ومراقبة استهلاك البيانات للشبكات والتطبيقات مع إمكانية التحكم في السرعة.

### Core Features
1. **واجهة تبويبي** - 3 أقسام رئيسية (الشبكات، التطبيقات، التقارير)
2. **تتبع استهلاك البيانات** - لكل شبكة وتطبيق مع فترات زمنية متعددة
3. **رسوم بيانية تفاعلية** - باستخدام fl_chart
4. **البحث والتصفية** - عبر جميع البيانات
5. **التحكم في السرعة** - محاكاة VPN محلي
6. **دعم RTL** - للغة العربية

### Architecture

#### Models
- **NetworkModel**: بيانات الشبكة مع استهلاك البيانات
- **AppModel**: بيانات التطبيق مع استهلاك البيانات لكل شبكة
- **SpeedLimitModel**: إعدادات التحكم في السرعة
- **DataUsage**: نموذج موحد لاستهلاك البيانات

#### Data Layer
- **DataProvider**: إدارة جميع البيانات مع State Management
- **SharedPreferences**: تخزين محلي للبيانات
- **Sample Data Generator**: بيانات تجريبية واقعية

#### UI Layer
**Main Navigation**:
- `HomePage`: الشاشة الرئيسية مع TabBar
- `NetworksTab`: قائمة الشبكات مع البحث والتصفية
- `AppsTab`: قائمة التطبيقات مع الترتيب
- `ReportsTab`: الرسوم البيانية والإحصائيات

**Detail Screens**:
- `NetworkDetailsScreen`: تفاصيل الشبكة مع التحكم في السرعة
- `AppDetailsScreen`: تفاصيل التطبيق مع الاستهلاك لكل شبكة

**Widgets**:
- `NetworkCard`: كارد عرض الشبكة
- `AppCard`: كارد عرض التطبيق
- `SearchBarWidget`: شريط البحث
- `TimeRangeSelector`: اختيار الفترة الزمنية
- `UsageChart`: الرسوم البيانية التفاعلية
- `StatsCard`: كاردات الإحصائيات

#### Features Implementation

**1. Data Tracking**:
- استهلاك يومي/أسبوعي/شهري/مخصص
- تتبع التحميل والرفع منفصلين
- ربط التطبيقات بالشبكات

**2. Speed Control**:
- محاكاة VPN محلي
- تحديد سرعة التحميل والرفع
- تفعيل/إلغاء الحدود

**3. Visualization**:
- Pie Charts للتطبيقات
- Bar Charts للشبكات  
- Line Charts للمقارنات
- تفاعل مع الرسوم

**4. Search & Filter**:
- البحث في الأسماء
- تصفية حسب الفترة الزمنية
- ترتيب حسب الاستهلاك

### Design System
- **Colors**: أزرق (#3B82F6)، أخضر (#10B981)، برتقالي (#F97316)
- **Typography**: Google Fonts - Inter
- **Layout**: Material Design 3 مع RTL
- **Animations**: انتقالات سلسة بين الشاشات

### Technical Stack
- **Framework**: Flutter 3.6+
- **State Management**: Provider
- **Charts**: fl_chart 0.68.0
- **Storage**: shared_preferences
- **Fonts**: google_fonts
- **Localization**: flutter_localizations

### File Structure
```
lib/
├── main.dart                     # Entry point
├── theme.dart                    # App theme configuration
├── models/                       # Data models
│   ├── network_model.dart
│   ├── app_model.dart
│   └── speed_limit_model.dart
├── providers/                    # State management
│   └── data_provider.dart
├── screens/                      # Main screens
│   ├── home_page.dart
│   ├── networks_tab.dart
│   ├── apps_tab.dart
│   ├── reports_tab.dart
│   ├── network_details_screen.dart
│   └── app_details_screen.dart
└── widgets/                      # Reusable components
    ├── network_card.dart
    ├── app_card.dart
    ├── search_bar_widget.dart
    ├── time_range_selector.dart
    ├── usage_chart.dart
    └── stats_card.dart
```

### Development Notes
- البيانات التجريبية تم إنشاؤها تلقائياً
- دعم كامل للغة العربية مع RTL
- تصميم متجاوب مع جميع أحجام الشاشات
- معالجة الأخطاء والحالات الفارغة
- تحسين الأداء مع lazy loading

### Future Enhancements
- إضافة Firebase للمزامنة
- تنبيهات استهلاك البيانات
- تصدير التقارير PDF
- مشاركة البيانات
- إعدادات متقدمة للتحكم