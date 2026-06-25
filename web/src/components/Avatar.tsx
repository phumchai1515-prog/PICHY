import type { UserProfile } from '../types'

// Shows the user's photo if set, otherwise their initial on the brand gradient.
export default function Avatar({ profile, size = 72 }: { profile: UserProfile; size?: number }) {
  const initial = (profile.name || 'พ').trim().slice(0, 1)
  if (profile.avatar) {
    return (
      <img
        src={profile.avatar}
        width={size}
        height={size}
        alt={profile.name}
        style={{ width: size, height: size, borderRadius: '50%', objectFit: 'cover', display: 'block' }}
      />
    )
  }
  return (
    <div
      style={{
        width: size, height: size, borderRadius: '50%',
        background: 'linear-gradient(var(--peach-grad-a),var(--peach-grad-b))',
        color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: size * 0.4, fontWeight: 700,
      }}
    >
      {initial}
    </div>
  )
}
