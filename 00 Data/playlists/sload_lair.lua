local SloadCells = {
    --- TODO: replace with sload lair cell name
    ['savel ancestral tomb'] = true,
}

return {
    {
        id = "AshVigil",
        priority = PlaylistPriority.Special,
        randomize = true,
        isValidCallback = function()
            --return true
            return Playback.rules.cellNameExact(SloadCells)
        end,
        tracks = {"music/AshVigil/Epl_Odo02.mp3"},
        playOneTrack = true,
    },
}
