{ lib, fetchurl, jdk, buildFHSEnv, unzip, makeDesktopItem, proEdition ? false }:
let
  version = "2023.10.1.1";

  product = if proEdition then {
    productName = "pro";
    productDesktop = "Burp Suite Professional Edition";
    hash = "sha256-xyEQVrfI9CS6div7vZuluKkIm36B9XqKZ9rH+1DjeD4=";
  } else {
    productName = "community";
    productDesktop = "Burp Suite Community Edition";
    hash = "sha256-lV1V92sxCiZ7AGjUNJHO9fkh3aUgt0+oISh7efBaOUA=";
  };

  src = fetchurl {
    name = "burpsuite.jar";
    urls = [
      "https://portswigger-cdn.net/burp/releases/download?product=${product.productName}&version=${version}&type=Jar"
      "https://portswigger.net/burp/releases/download?product=${product.productName}&version=${version}&type=Jar"
      "https://web.archive.org/web/https://portswigger.net/burp/releases/download?product=${product.productName}&version=${version}&type=Jar"
    ];
    hash = product.hash;
  };

  name = "burpsuite-${version}";
  description = "An integrated platform for performing security testing of web applications";
  desktopItem = makeDesktopItem rec {
    name = "burpsuite";
    exec = name;
    icon = name;
    desktopName = product.productDesktop;
    comment = description;
    categories = [ "Development" "Security" "System" ];
  };

in
buildFHSEnv {
  inherit name;

  runScript = "${jdk}/bin/java -jar ${src}";

  targetPkgs = pkgs: with pkgs; [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libudev0-shim
    libxkbcommon
    mesa.drivers
    nspr
    nss
    pango
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
  ];

  extraInstallCommands = ''
    mv "$out/bin/${name}" "$out/bin/burpsuite" # name includes the version number
    mkdir -p "$out/share/pixmaps"
    ${lib.getBin unzip}/bin/unzip -p ${src} resources/Media/icon64${product.productName}.png > "$out/share/pixmaps/burpsuite.png"
    cp -r ${desktopItem}/share/applications $out/share
  '';

  meta = with lib; {
    inherit description;
    longDescription = ''
      Burp Suite is an integrated platform for performing security testing of web applications.
      Its various tools work seamlessly together to support the entire testing process, from
      initial mapping and analysis of an application's attack surface, through to finding and
      exploiting security vulnerabilities.
    '';
    homepage = "https://portswigger.net/burp/";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.unfree;
    platforms = jdk.meta.platforms;
    hydraPlatforms = [ ];
    maintainers = with maintainers; [ arcayr bennofs ];
  };
}
