export type AttendanceStatus = 'present' | 'absent' | 'not_concerned'

export type NavKey =
  | 'home'
  | 'people'
  | 'person-types'
  | 'groups'
  | 'attendance'
  | 'history'
  | 'statistics'
  | 'settings'

export type AttendanceChannelType = 'registered' | 'public'

export interface Person {
  id: string
  firstName: string
  lastName: string
  type: string
  groups: string[]
  active: boolean
}
