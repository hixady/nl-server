# NL Server

## Database Setup

Set the `DATABASE_URL` environment variable before running the server.

Example:

```sh
DATABASE_URL=postgres://neverlose:neverlose@localhost/neverlose
```

## Build Requirements

- Cargo / Rust toolchain
- `flatc` from FlatBuffers releases: https://github.com/google/flatbuffers/releases

Make sure `flatc` is available in `PATH`.

## Build

```sh
cargo build
```
