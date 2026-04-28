use std::path::Path;
use std::process::Command;

fn main() {
    let out_dir = std::env::var("OUT_DIR").unwrap();
    let fbs_path = Path::new("../module.fbs");

    println!("cargo:rerun-if-changed=../module.fbs");

    let status = Command::new("flatc")
        .args(["--rust", "-o", &out_dir, fbs_path.to_str().unwrap()])
        .status()
        .expect("Failed to run flatc. Ensure flatc is in PATH.");

    assert!(status.success(), "flatc exited with error");
}
