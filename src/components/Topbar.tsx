import { Bell, Menu, Search } from 'lucide-react'

interface TopbarProps {
  title: string
  onMenu: () => void
}

export function Topbar({ title, onMenu }: TopbarProps) {
  return (
    <header className="topbar">
      <div className="topbar-start">
        <button className="icon-button mobile-menu" onClick={onMenu} aria-label="فتح القائمة">
          <Menu size={21} />
        </button>
        <div>
          <div className="eyebrow">نظام إدارة الحضور</div>
          <h1>{title}</h1>
        </div>
      </div>
      <div className="topbar-actions">
        <button className="icon-button" aria-label="بحث"><Search size={19} /></button>
        <button className="icon-button" aria-label="الإشعارات"><Bell size={19} /></button>
        <div className="avatar">م</div>
      </div>
    </header>
  )
}
