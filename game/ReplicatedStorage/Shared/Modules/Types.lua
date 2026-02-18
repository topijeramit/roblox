export type PetInstance = {
	Uid: string,
	PetId: string,
	Stars: number,
	Equipped: boolean,
	CreatedAt: number,
}

export type PlayerProfile = {
	Coins: number,
	LastSeen: number,
	Pets: { [string]: PetInstance },
}

return {}
