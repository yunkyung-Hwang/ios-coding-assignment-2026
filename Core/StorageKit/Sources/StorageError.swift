public enum StorageError: Error, Sendable, Equatable {
    case write(String)
    case read(String)
}
