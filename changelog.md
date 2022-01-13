# Changelog

## 2022-01-13

### MapOverrides

Map overrides feature can be used to configure map specific rules, currently the
only supported property is `Song`, it can be used to override the song played on
the map.

`bEnableMapOverrides` completely disables this feature in case if it messes
things up.

`bOverrideServerPackages` should be enabled in case you're loading songs from
custom pacakges.

Configuration Example:

```ini
[MVES.MapOverridesConfig]
MapOverridesVersion=1
MapOverrides[0]=DM-Deck16][?Song=Organic.Organic
MapOverrides[1]=DM-Gothic?Song=Mannodermaus-20200222.20200222
MapOverrides[2]=Song==Phantom.Phantom?Song=X-void_b.X-void_b
```

### Fast Player Detection

I've added a fast player detection that triggers on the same tick when the
player joins the server, instead of waiting for the imter interval to pass.

The timer interval is still there as a safety net for gametypes that have custom
player ID assignment.
