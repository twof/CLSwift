/// Exists for conveinience
/// Flag is an Option that either exists or doesn't and takes no parameters
public class Flag: Option<Bool> {
    public init(triggers: [String], help: String, onExecution: @escaping ([Bool], State) -> State) {
        super.init(triggers: triggers, help: help, numParams: .none, onExecution: onExecution)
    }
}
