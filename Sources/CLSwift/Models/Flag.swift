/// Exists for conveinience
/// Flag is an Option that either exists or doesn't and takes no parameters
public class Flag<FS: StateType>: Option<Bool, FS> {
    public init(triggers: [String], help: String, state: FS, onExecution: @escaping (FS) -> FS) {
        super.init(triggers: triggers, help: help, state: state, numParams: .none) { (_, theState) -> FS in
            return onExecution(theState)
        }
    }
}
