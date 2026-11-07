import {
  BarChart3,
  CalendarCheck2,
  ClipboardList,
  Group,
  Home,
  Settings,
  Tags,
  Users,
} from 'lucide-react'
import type { NavKey } from '../types'

interface SidebarProps {
  active: NavKey
  onNavigate: (key: NavKey) => void
}

const items: { key: NavKey; label: string; icon: typeof Home }[] = [
  { key: 'home', label: 'الرئيسية', icon: Home },
  { key: 'people', label: 'الأشخاص', icon: Users },
  { key: 'person-types', label: 'أنواع الأشخاص', icon: Tags },
  { key: 'groups', label: 'المجموعات', icon: Group },
  { key: 'attendance', label: 'الحضور', icon: CalendarCheck2 },
  { key: 'history', label: 'السجل', icon: ClipboardList },
  { key: 'statistics', label: 'الإحصائيات', icon: BarChart3 },
  { key: 'settings', label: 'الإعدادات', icon: Settings },
]

export function Sidebar({ active, onNavigate }: SidebarProps) {
  return (
    <aside className="sidebar">
      <div className="brand">
        <div className="brand-mark">ح</div>
        <div>
          <div className="brand-title">نظام الحضور</div>
          <div className="brand-subtitle">Attendance Management</div>
        </div>
      </div>

      <nav className="nav-list" aria-label="التنقل الرئيسي">
        {items.map(({ key, label, icon: Icon }) => (
          <button
            key={key}
            className={`nav-item ${active === key ? 'active' : ''}`}
            onClick={() => onNavigate(key)}
          >
            <Icon size={19} strokeWidth={1.9} />
            <span>{label}</span>
          </button>
        ))}
      </nav>

      <div className="sidebar-footer">
        <div className="status-dot" />
        <span>متصل</span>
      </div>
    </aside>
  )
}
