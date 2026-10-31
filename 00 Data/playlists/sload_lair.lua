local SloadCells = {
    ['sload lair'] = true,
}

return {
    {
        id = "AshVigil",
        priority = PlaylistPriority.CellExact,
        randomize = true,
        isValidCallback = function()
            return Playback.rules.cellNameExact(SloadCells)
        end,
        tracks = {"AshVigil/Epl_Odo02.mp3"},
        playOneTrack = true,
    },
}
