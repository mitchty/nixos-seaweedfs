{ lib
, fetchFromGitHub
, buildGo118Module
, testers
, seaweedfs
}:

buildGo118Module rec {
  pname = "seaweedfs";
  version = "3.32";

  src = fetchFromGitHub {
    owner = "seaweedfs";
    repo = "seaweedfs";
    rev = version;
    sha256 = "sha256-GMOLlkBfY3ShVojdRrmpMYgoea52kq4aXr/oZj5bJWo=";
  };

  vendorSha256 = "sha256-cEzPKx54rssyAytYenIcud3K0f7xuO8WzE8wdMqZipE=";

  subPackages = [ "weed" ];

  postInstall = ''
    install -dm755 $out/sbin
    ln -sf $out/bin/weed $out/sbin/mount.weed
  '';

  passthru.tests.version =
    testers.testVersion { package = seaweedfs; command = "weed version"; };

  latest = "curl --location --silent 'https://api.github.com/repos/chrislusf/seaweedfs/releases/latest' | jq -r '.tag_name'";

  meta = with lib; {
    description = "Simple and highly scalable distributed file system";
    homepage = "https://github.com/chrislusf/seaweedfs";
    maintainers = with maintainers; [ cmacrae ];
    mainProgram = "weed";
    license = licenses.asl20;
  };
}
