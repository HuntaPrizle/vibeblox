--!strict
-- Pure validation; the server supplies distance and claim state, never the client.
local SmokeLogic = {}

function SmokeLogic.CanClaim(request: unknown, distance: number, claimed: boolean): boolean
	return request == "starter-coin" and distance >= 0 and distance <= 12 and not claimed
end

return SmokeLogic
