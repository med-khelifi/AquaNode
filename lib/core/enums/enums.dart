enum ValveState { open, closed, unknown }
enum PhysicalState { verified, unverified }
enum CommandAction { open, close }
enum CommandStatus { pending, received, executed, failed, expired, cancelled }
enum ConnectionStatus { online, offline, neverConnected } // derived, never stored