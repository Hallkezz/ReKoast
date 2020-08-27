function PassengerFunction( args, player )
	if args.vehicle then
		if args.vehicle:GetOccupants() ~= nil then
			local players = args.vehicle:GetOccupants()

			if (#players == 1) then
				player:EnterVehicle( args.vehicle, VehicleSeat.Passenger )
			end
		end
	end
end

Network:Subscribe( "EnterPassenger", PassengerFunction )