function EjectFunction( args, player )
	if player:GetVehicle() then
		player:EnterVehicle( args.vehicle, VehicleSeat.RooftopStunt )
	end
end

Network:Subscribe( "EjectPassenger", EjectFunction )