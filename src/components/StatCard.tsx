interface StatCardProps {
  label: string
  value: string
  hint: string
  tone?: 'blue' | 'green' | 'amber' | 'slate'
}

export function StatCard({ label, value, hint, tone = 'blue' }: StatCardProps) {
  return (
    <div className="stat-card">
      <div className={`stat-icon ${tone}`} />
      <div>
        <div className="stat-label">{label}</div>
        <div className="stat-value">{value}</div>
        <div className="stat-hint">{hint}</div>
      </div>
    </div>
  )
}
