// Stub implementation for pthread_atfork
// This provides a dummy implementation to satisfy linker requirements

int pthread_atfork(void (*prepare)(void), void (*parent)(void), void (*child)(void)) {
    // Return success without actually registering handlers
    // This is safe for most use cases where atfork handlers aren't critical
    return 0;
}
