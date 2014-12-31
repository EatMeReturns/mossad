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
	Base.init(self, level and level or House.getDifficulty())
end