{
  lib,
  python3,
  fetchurl,
  wrapGAppsHook3,
  gobject-introspection,
  at-spi2-core,
  gdk-pixbuf,
  gtk3,
  harfbuzz,
  pango,
  ibus,
  libayatana-appindicator,
  libnotify,
  procps,
  wl-clipboard,
  wtype,
  xclip,
  xdotool,
  ydotool,
}:
let
  py = python3.pkgs;

  runtimeDeps = with py; [
    faster-whisper
    numpy
    onnxruntime
    wordfreq
    sounddevice
    evdev
    pynput
    pystray
    pillow
  ];

  systemPython = python3.withPackages (
    ps:
    runtimeDeps
    ++ [
      ps.pygobject3
    ]
  );
in
py.buildPythonApplication rec {
  pname = "python-voiceio";
  version = "1.15.1";
  pyproject = true;

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/98/3b/f62fbb465ec3a2e4311723ac5d8bf4293553609c12d3eb334b92f4b90956/python_voiceio-${version}.tar.gz";
    hash = "sha256-RT1xSI6peDPhdNcqsRJnimzQ1MZ6WI/V9IswQAMfh2M=";
  };

  dependencies = runtimeDeps;

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    ibus
    libayatana-appindicator
  ];

  dontWrapGApps = true;

  pythonImportsCheck = [
    "voiceio"
    "voiceio.core.engine"
  ];

  doCheck = false;

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      ibus
      libnotify
      procps
      wl-clipboard
      wtype
      xclip
      xdotool
      ydotool
    ])
    "--prefix"
    "GI_TYPELIB_PATH"
    ":"
    (lib.makeSearchPath "lib/girepository-1.0" [
      at-spi2-core
      gdk-pixbuf
      gobject-introspection
      gtk3
      harfbuzz
      ibus
      libayatana-appindicator
      pango.out
    ])
    "--set"
    "VOICEIO_SYSTEM_PYTHON"
    "${systemPython}/bin/python3"
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  passthru = {
    inherit systemPython;
  };

  meta = {
    description = "Voice dictation for Linux. Speak → text, locally, instantly";
    homepage = "https://voiceio.dev/";
    changelog = "https://github.com/Hugo0/voiceio/releases";
    license = lib.licenses.mit;
    mainProgram = "voiceio";
    platforms = lib.platforms.linux;
  };
}
