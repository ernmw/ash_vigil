local SloadCells = {
    ['slug tunnels, lair'] = true,
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
