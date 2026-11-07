import { useState } from 'react'
import { Sidebar } from './components/Sidebar'
import { Topbar } from './components/Topbar'
import { HomePage } from './pages/HomePage'
import { PlaceholderPage } from './pages/PlaceholderPage'
import type { NavKey } from './types'
import './styles.css'

const pageMeta: Record<Exclude<NavKey, 'home'>, { title: string; description: string }> = {
  people: { title: 'الأشخاص', description: 'إدارة الأشخاص وبياناتهم وعضوياتهم في المجموعات.' },
  'person-types': { title: 'أنواع الأشخاص', description: 'تعريف وإدارة أنواع الأشخاص المستخدمة في النظام.' },
  groups: { title: 'المجموعات', description: 'إنشاء المجموعات وإدارة أعضائها دون حذف الأشخاص عند حذف المجموعة.' },
  attendance: { title: 'الحضور', description: 'إنشاء الاجتماعات والأنشطة وتحديد قنوات الحضور المناسبة لكل جمهور.' },
  history: { title: 'السجل', description: 'عرض الاجتماعات السابقة وإعادة فتح بيانات الحضور والتقارير.' },
  statistics: { title: 'الإحصائيات', description: 'تحليل الحضور حسب الفترة والنوع والمجموعة والخصائص المختلفة.' },
  settings: { title: 'الإعدادات', description: 'إدارة المظهر والحقول المخصصة وأنواع الأنشطة والنسخ الاحتياطي.' },
}

export default function App() {
  const [active, setActive] = useState<NavKey>('home')
  const [sidebarOpen, setSidebarOpen] = useState(false)

  const navigate = (key: NavKey) => {
    setActive(key)
    setSidebarOpen(false)
  }

  return (
    <div className="app-shell">
      <div className={`mobile-overlay ${sidebarOpen ? 'visible' : ''}`} onClick={() => setSidebarOpen(false)} />
      <div className={`sidebar-wrap ${sidebarOpen ? 'open' : ''}`}>
        <Sidebar active={active} onNavigate={navigate} />
      </div>
      <main className="main-content">
        <Topbar title={active === 'home' ? 'الرئيسية' : pageMeta[active].title} onMenu={() => setSidebarOpen(true)} />
        <div className="content-wrap">
          {active === 'home' ? (
            <HomePage onCreateActivity={() => navigate('attendance')} />
          ) : (
            <PlaceholderPage title={pageMeta[active].title} description={pageMeta[active].description} />
          )}
        </div>
      </main>
    </div>
  )
}
