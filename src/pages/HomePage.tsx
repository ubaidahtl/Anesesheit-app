import { ArrowLeft, CalendarPlus, QrCode, UsersRound } from 'lucide-react'
import { StatCard } from '../components/StatCard'

interface HomePageProps { onCreateActivity: () => void }

export function HomePage({ onCreateActivity }: HomePageProps) {
  return (
    <div className="page-stack">
      <section className="welcome-card">
        <div>
          <span className="pill">لوحة التحكم</span>
          <h2>مرحباً بك في نظام الحضور</h2>
          <p>إدارة الأشخاص والمجموعات والاجتماعات والحضور من مكان واحد.</p>
        </div>
        <button className="primary-button" onClick={onCreateActivity}>
          <CalendarPlus size={18} />
          إنشاء اجتماع
        </button>
      </section>

      <section className="stats-grid">
        <StatCard label="الأشخاص" value="128" hint="أشخاص نشطون" tone="blue" />
        <StatCard label="المجموعات" value="12" hint="مجموعات مسجلة" tone="green" />
        <StatCard label="اجتماعات هذا الشهر" value="18" hint="3 اجتماعات قادمة" tone="amber" />
        <StatCard label="نسبة الحضور" value="91.4%" hint="آخر 30 يوماً" tone="slate" />
      </section>

      <section className="dashboard-grid">
        <div className="panel">
          <div className="panel-header">
            <div>
              <h3>الاجتماعات القادمة</h3>
              <p>آخر الأنشطة المجدولة</p>
            </div>
            <button className="text-button">عرض الكل <ArrowLeft size={15} /></button>
          </div>
          <div className="meeting-list">
            <div className="meeting-row">
              <div className="date-box"><strong>15</strong><span>نوفمبر</span></div>
              <div className="meeting-main"><strong>اجتماع أولياء الأمور والمعلمين</strong><span>18:00 · اجتماع عام</span></div>
              <div className="meeting-badge">QR + رابط</div>
            </div>
            <div className="meeting-row">
              <div className="date-box"><strong>18</strong><span>نوفمبر</span></div>
              <div className="meeting-main"><strong>اجتماع لجنة التنظيم</strong><span>17:30 · لجنة</span></div>
              <div className="meeting-badge">مسجلون</div>
            </div>
            <div className="meeting-row">
              <div className="date-box"><strong>22</strong><span>نوفمبر</span></div>
              <div className="meeting-main"><strong>النشاط الأسبوعي</strong><span>16:00 · نشاط</span></div>
              <div className="meeting-badge">يدوي</div>
            </div>
          </div>
        </div>

        <div className="panel quick-panel">
          <div className="panel-header"><div><h3>اختصارات</h3><p>إجراءات سريعة</p></div></div>
          <button className="quick-action" onClick={onCreateActivity}><span><CalendarPlus size={18} /></span><div><strong>إنشاء اجتماع جديد</strong><small>حدد الأشخاص وقنوات الحضور</small></div></button>
          <button className="quick-action"><span><UsersRound size={18} /></span><div><strong>إضافة شخص</strong><small>إنشاء سجل شخص جديد</small></div></button>
          <button className="quick-action"><span><QrCode size={18} /></span><div><strong>إدارة QR</strong><small>مراجعة قنوات الاجتماعات</small></div></button>
        </div>
      </section>
    </div>
  )
}
