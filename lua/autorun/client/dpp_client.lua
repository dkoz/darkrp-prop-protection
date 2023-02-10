timer.Create( "dpp:clearDecals", dpp.clearDecals, 0, function()
	LocalPlayer():ConCommand("r_cleardecals")
end)