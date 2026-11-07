# Ubaidah Attendance App

Initial project foundation for the attendance-management PWA.

## Current navigation

- الرئيسية
- الأشخاص
- أنواع الأشخاص
- المجموعات
- الحضور
- السجل
- الإحصائيات
- الإعدادات

## Current domain decisions

- A person is a single entity and may belong to multiple groups.
- Attendance is unique per activity + person.
- An activity may contain multiple attendance channels.
- Registered-person channels identify existing people.
- Public channels create event-specific public registrations and do not match/link to master people.
- Each channel can later expose both a QR code and a direct link.
- Registration windows are configurable per channel.

## Run locally

```bash
npm install
npm run dev
```

## Supabase

Copy `.env.example` to `.env` and add the Supabase project URL and anon key.

The first database migration is in:

`supabase/migrations/0001_initial_schema.sql`
