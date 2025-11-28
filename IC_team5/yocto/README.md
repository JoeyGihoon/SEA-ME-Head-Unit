# Instrument Cluster Yocto Project

이 저장소는 계기판(Instrument Cluster) 이미지를 Yocto로 빌드하기 위한 트리입니다. 헤드유닛 관련 레이어/레시피는 제거하고 IC만 포함합니다.

## 구성
- `poky`, `meta-raspberrypi`
- `meta-openembedded` (meta-oe, meta-python, meta-networking, meta-multimedia, meta-python2, meta-homeassistant)
- `meta-qt5`, `meta-wayland`, `meta-ivi`
- 팀 레이어: `meta-ui`(IC 앱/레시피), `meta-team5`(이미지 패키지 묶음)
- `build/conf/` : `bblayers.conf`, `local.conf`

## 빌드 전 준비


1) 네트워크 IP 설정:
`meta-ui/recipes-ic/files/IC_someip/json/IC.json`의 `unicast`를 실제 IC 장비의 NIC IP(`ip addr` 결과)로 수정하세요. 이 값이 런타임에 vsomeip가 바인드/광고할 주소입니다.

## 빌드 방법
```bash
# 1. 환경 설정
$ source poky/oe-init-build-env build

# 2. 이미지 빌드 (계기판)
$ bitbake instrument-cluster-image
```
빌드 결과: `build/tmp/deploy/images/raspberrypi4-64/` 내 WIC/SD 이미지 등.

## 런타임 위치 안내
- 앱 바이너리: `/opt/IC_someip/build/IC_someip`
- vsomeip 설정: `/opt/IC_someip/json/IC.json`
- 실행 스크립트: `/usr/bin/ic`, `/usr/bin/set_ip`, `/usr/bin/select`(IC만 실행)

## 참고
- 레이어 이름을 `meta-team5`로 사용합니다. `build/conf/bblayers.conf`가 동일한 경로/이름을 가리키는지 확인하세요.
- 헤드유닛 관련 이미지/레시피가 없으므로 `head-unit-image` 타깃은 빌드되지 않습니다.
