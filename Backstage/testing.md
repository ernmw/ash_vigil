# Testing

## Vandus

```
PCRaiseRank "Temple"
PCRaiseRank "Temple"
coc "Molag Mar, St. Veloth's Hostel"
```

Talk with Firsylla.

```
coc "Molag Mar, The Pilgrim's Rest"
```

Talk with Keerin.

```
coc "Vandus Ancestral Tomb"
```

Drop the pot.

```
coc "Molag Mar, The Pilgrim's Rest"
```

Talk with Keerin.

## Savel

To skip to this quest:
```
Journal "AV_mm_vandus" 100
```

```
coc "Molag Mar, St. Veloth's Hostel"
```

Talk with Ondar.

```
coc "Savel Ancestral Tomb"
```

Pick up Thief's Journal.

Now you have to test three branches:

- Talk to Ondar and finish the quest early.
- Talk to Savel and offer to help him, and actually do.
- Talk to Savel and offer to help him. But when you talk to Baren, double-cross Savel.

```
coc "Molag Mar, Redoran Stronghold"
```

```
coc "Vivec, Hlaalu Vaults"
```

## Permission to Audit

Skip to this:
```
Journal "AV_therana_permission 10"
```

```
coc "Tel Branora, Upper Tower: Therana's Chamber"
```

```
Player->AddItem "food_kwama_egg_01" 22
Player->AddItem "food_kwama_egg_02" 33
```

## Arano and Beran Audit

```
Journal "AV_therana_permission" 100
coc "Molag Mar, St. Veloth's Hostel"
```

Talk to Firsylla.

Lots of branchs to test:

- Go to Arano first, and do everything that DS wants, including the orb, finishing Daedric Detective, before returning to KOTD.
- Go to Arano first and accept DS's deal, but don't do anything. Then clear Beran. Then talk to KOTD and lie.
- Kill DS and GS, then talk to KOTD to finish.

Do all that again, but with or without the bloodied journal.

```
coc "Arano Ancestral Tomb"
```

```
coc "Beran Ancestral Tomb"
```
