{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, asciidoctor
, installShellFiles
}: let
  name = "qrtool";
  version = "0.8.5";
in rustPlatform.buildRustPackage {
  pname = name;
  inherit version;

  src = fetchFromGitHub {
    owner = "sorairolake";
    repo = name;
    rev = "v${version}";
    sha256 = "sha256-jrvNZGO1VIDo6Mz3NKda1C7qZUtF9T00CAFK8yoGWjc=";
  };

  cargoSha256 = "sha256-JOnvlabCr3fZsIIRc2qTjf50Ga83zL8Aoo2sqzMBs7g=";

  nativeBuildInputs = [ asciidoctor installShellFiles ];

  postInstall = ''
    # Built by ./build.rs using `asciidoctor`
    installManPage ./target/*/release/build/${name}*/out/*.?

    installShellCompletion --cmd ${name} \
      --bash <($out/bin/${name} --generate-completion bash) \
      --fish <($out/bin/${name} --generate-completion fish) \
      --zsh <($out/bin/${name} --generate-completion zsh)
  '';

  meta = with lib; {
    maintainers = with maintainers; [ philiptaron ];
    description = "An utility for encoding or decoding QR code";
    license = licenses.asl20;
    homepage = "https://sorairolake.github.io/${name}/book/index.html";
    changelog = "https://sorairolake.github.io/${name}/book/changelog.html";
    mainProgram = name;
  };
}
