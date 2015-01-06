BloodElement = extend(Mod)

BloodElement.name = 'Blood Element' --Red, Rage

function BloodElement:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

-----------------------------------------------------------------------

WaterElement = extend(Mod) --Blue, Ocean

WaterElement.name = 'Water Element'

function WaterElement:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

-----------------------------------------------------------------------

ElectricElement = extend(Mod) --Yellow, Lightning

ElectricElement.name = 'Electric Element'

function ElectricElement:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

-----------------------------------------------------------------------

EarthElement = extend(Mod) --Green, Moss

EarthElement.name = 'Earth Element'

function EarthElement:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

-----------------------------------------------------------------------

RoyalElement = extend(Mod) --Purple, Imperial

RoyalElement.name = 'Royal Element'

function RoyalElement:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

-----------------------------------------------------------------------

FlameElement = extend(Mod) --Orange, Tiger

FlameElement.name = 'Flame Element'

function FlameElement:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

-----------------------------------------------------------------------

VoidElementGreen = extend(Mod) --Black, Onyx

VoidElementGreen.name = 'Void Element Green'

function VoidElementGreen:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

VoidElementPurple = extend(Mod) --Black, Onyx

VoidElementPurple.name = 'Void Element Purple'

function VoidElementPurple:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

VoidElementOrange = extend(Mod) --Black, Onyx

VoidElementOrange.name = 'Void Element Orange'

function VoidElementOrange:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

-----------------------------------------------------------------------

IridescentElementGreen = extend(Mod) --Rainbow, Iris

IridescentElementGreen.name = 'Iridescent Element Green'

function IridescentElementGreen:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

IridescentElementPurple = extend(Mod) --Rainbow, Iris

IridescentElementPurple.name = 'Iridescent Element Purple'

function IridescentElementPurple:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

IridescentElementOrange = extend(Mod) --Rainbow, Iris

IridescentElementOrange.name = 'Iridescent Element Orange'

function IridescentElementOrange:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

-----------------------------------------------------------------------

PureElementGreenOrange = extend(Mod) --White, Lace

PureElementGreenOrange.name = 'Pure Element Green Orange'

function PureElementGreenOrange:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

PureElementGreenPurple = extend(Mod) --White, Lace

PureElementGreenPurple.name = 'Pure Element Green Purple'

function PureElementGreenPurple:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

PureElementPurpleOrange = extend(Mod) --White, Lace

PureElementPurpleOrange.name = 'Pure Element Purple Orange'

function PureElementPurpleOrange:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

PureElementDoubleOrange = extend(Mod) --White, Lace

PureElementDoubleOrange.name = 'Pure Element Double Orange'

function PureElementDoubleOrange:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

PureElementDoubleGreen = extend(Mod) --White, Lace

PureElementDoubleGreen.name = 'Pure Element Double Green'

function PureElementDoubleGreen:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

PureElementDoublePurple = extend(Mod) --White, Lace

PureElementDoublePurple.name = 'Pure Element Double Purple'

function PureElementDoublePurple:init(amount)
	amount = amount or House.getDifficulty(false, true)
	Mod.init(self, amount)
end

-----------------------------------------------------------------------

--GreenOrange, PurpleOrange, GreenPurple

BloodElement.mods = {{ElectricElement, FlameElement},
					 {WaterElement, RoyalElement},
					 {EarthElement, VoidElementGreen}}

WaterElement.mods = {{ElectricElement, EarthElement},
					 {BloodElement, RoyalElement},
					 {FlameElement, VoidElementOrange}}

ElectricElement.mods = {{WaterElement, EarthElement},
						{BloodElement, FlameElement},
						{RoyalElement, VoidElementPurple}}

EarthElement.mods = {{EarthElement, IridescentElementGreen},
					 {BloodElement, VoidElementGreen}}

RoyalElement.mods = {{RoyalElement, IridescentElementPurple},
					 {ElectricElement, VoidElementPurple}}

FlameElement.mods = {{FlameElement, IridescentElementOrange},
					 {WaterElement, VoidElementOrange}}

VoidElementGreen.mods = {{IridescentElementOrange, PureElementGreenOrange},
						 {IridescentElementPurple, PureElementGreenPurple},
						 {IridescentElementGreen, PureElementDoubleGreen}}

VoidElementOrange.mods = {{IridescentElementOrange, PureElementDoubleOrange},
						  {IridescentElementPurple, PureElementPurpleOrange},
						  {IridescentElementGreen, PureElementGreenOrange}}

VoidElementPurple.mods = {{IridescentElementOrange, PureElementPurpleOrange},
						  {IridescentElementPurple, PureElementDoublePurple},
						  {IridescentElementGreen, PureElementGreenPurple}}

IridescentElementGreen.mods = {{VoidElementOrange, PureElementGreenOrange},
								{VoidElementPurple, PureElementGreenPurple},
								{VoidElementGreen, PureElementDoubleGreen}}

IridescentElementOrange.mods = {{VoidElementOrange, PureElementDoubleOrange},
								{VoidElementPurple, PureElementPurpleOrange},
								{VoidElementGreen, PureElementGreenOrange}}

IridescentElementPurple.mods = {{VoidElementOrange, PureElementPurpleOrange},
								{VoidElementPurple, PureElementDoublePurple},
								{VoidElementGreen, PureElementGreenPurple}}