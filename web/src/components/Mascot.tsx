export function MascotFull({ size = 160 }: { size?: number }) {
  return <img src="mascot-full.svg" width={size} height={size} alt="น้องพีช" style={{ display: 'block' }} />
}

export function MascotHead({ size = 80 }: { size?: number }) {
  return <img src="mascot-head.svg" width={size} height={size} alt="น้องพีช" style={{ display: 'block' }} />
}
