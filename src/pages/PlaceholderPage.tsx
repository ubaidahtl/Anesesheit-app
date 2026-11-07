interface PlaceholderPageProps {
  title: string
  description: string
}

export function PlaceholderPage({ title, description }: PlaceholderPageProps) {
  return (
    <div className="page-stack">
      <div className="panel empty-page">
        <div className="empty-icon">✦</div>
        <h2>{title}</h2>
        <p>{description}</p>
        <span className="coming-soon">هذه الصفحة جزء من الهيكل الأولي وسيتم بناء وظائفها في الخطوات التالية.</span>
      </div>
    </div>
  )
}
