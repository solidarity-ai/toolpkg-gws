use std::env;
use std::process;

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();

    if args == ["users", "list", "--format", "json"] {
        println!(r#"{{"users":[{{"primaryEmail":"wasm-ada@example.com"}}]}}"#);
        return;
    }

    eprintln!("unsupported args: {:?}", args);
    process::exit(2);
}
