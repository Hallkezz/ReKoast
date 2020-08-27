class 'Lost'

function Lost:__init()
	Network:Subscribe( "Weather", self, self.Weather )
	Network:Subscribe( "WeatherC", self, self.WeatherC )
end

function Lost:Weather( args, sender )
	sender:SetWeatherSeverity( 2 )
end

function Lost:WeatherC( args, sender )
	sender:SetWeatherSeverity( DefaultWorld:GetWeatherSeverity() )
end

lost = Lost()