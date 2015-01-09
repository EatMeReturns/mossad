Agate = extend(Base)

Agate.mods = {{BloodElement, RageAgate},
			  {WaterElement, OceanAgate},
			  {ElectricElement, LightningAgate},
			  {EarthElement, MossAgate}, 
			  {FlameElement, TigerAgate}, 
			  {RoyalElement, ImperialAgate},
			  {IridescentElementGreen, IrisAgate},
			  {IridescentElementPurple, IrisAgate},
			  {IridescentElementOrange, IrisAgate},
			  {VoidElementGreen, OnyxAgate},
			  {VoidElementPurple, OnyxAgate},
			  {VoidElementOrange, OnyxAgate},
			  {PureElementDoubleOrange, LaceAgate},
			  {PureElementDoubleGreen, LaceAgate},
			  {PureElementDoublePurple, LaceAgate},
			  {PureElementGreenOrange, LaceAgate},
			  {PureElementPurpleOrange, LaceAgate},
			  {PureElementGreenPurple, LaceAgate}}

Agate.name = 'Agate'

function Agate:init(level) --any agate with a 'materials' in the init REQUIRES the arg
	Base.init(self, math.min(20, level and level or House.getDifficulty(false, true)))
end

function calculateAgateAmount(level)
	return 1 * (level and (level > 1 and (level ^ (1 + level / 10)) ^ (1/3) or 1) or 1)
end