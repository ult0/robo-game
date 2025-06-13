class_name Signals

## Given a list of signals, waits until each signal has been recieved at least
## once, then returns all of the signals' return values in the same order as they were given.
static func all(signals: Array[Signal]) -> Array[Variant]:
    var signal_emissions: Array = []
    signal_emissions.resize(signals.size())
    signal_emissions.fill(null)
    for i in range(signals.size()):
        signal_emissions[i] = await signals[i]
    return signal_emissions