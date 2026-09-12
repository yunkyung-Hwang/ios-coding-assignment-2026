WORKSPACE = Assignment.xcworkspace
SCHEME    = App

# 사용 가능한 iOS 시뮬레이터를 런타임 선택. 기기 이름 고정은 환경 따라 깨짐
SIM_ID = $(shell xcrun simctl list devices available --json \
	| python3 -c "import json,sys;d=json.load(sys.stdin)['devices'];\
print([x['udid'] for k,v in d.items() if 'iOS' in k for x in v][0])")
DEST   = platform=iOS Simulator,id=$(SIM_ID)

.PHONY: generate open build test clean

generate:
	tuist generate --no-open

open:
	tuist generate

build:
	xcodebuild build -workspace $(WORKSPACE) -scheme $(SCHEME) -destination "$(DEST)"

test:
	xcodebuild test -workspace $(WORKSPACE) -scheme $(SCHEME) -destination "$(DEST)"

clean:
	rm -rf Derived *.xcworkspace
	find . -name '*.xcodeproj' -not -path './.git/*' -exec rm -rf {} +
