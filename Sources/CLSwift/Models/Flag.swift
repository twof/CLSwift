/// Exists for conveinience
/// Flag is an Option that either exists or doesn't and takes no parameters
public class Flag: Option<Bool> {
    public init(triggers: [String], help: String, state: State, onExecution: @escaping (State) -> State) {
        super.init(triggers: triggers, help: help, state: state, numParams: .none) { (_, state) -> State in
            onExecution(state)
        }
    }
}
