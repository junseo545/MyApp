import 'package:coding/Real/BattleUpload.dart';
import 'package:coding/Real/Camera.dart';
import 'package:coding/Real/Chat.dart';
import 'package:coding/Real/HumanPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive/hive.dart';

class BattlePage extends StatefulWidget {
  final int selectindex;
  const BattlePage({super.key, required this.selectindex});

  @override
  State<BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  int currentPageIndex = 0;
  int count = 0;
  late List<Widget> _pages; // 페이지 리스트를 초기화하기 위해 late 키워드 사용

  @override
  void initState() {
    super.initState();
    _pages = [
      BattleHomePage(
        uploadBattle: '',
        categoryindex: widget.selectindex,
      ),
      Search(),
      Camera(),
      Search(),
      HumanPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 0) {
        if (currentPageIndex != 0 && count == 0) {
          // 처음에 다른 페이지에서 0으로 돌아오면 count를 1로 설정
          count = 1;
        } else if (count == 1) {
          // 0을 두 번 누르면 Navigator.pop
          Navigator.pop(context);
        } else {
          // 처음 앱이 실행될 때 currentPageIndex가 0이면 바로 pop
          Navigator.pop(context);
        }
      } else {
        // 다른 인덱스를 누르면 count 초기화
        count = 0;
      }
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[currentPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentPageIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call),
            label: '릴스',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: '카메라',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}

class BattleHomePage extends StatefulWidget {
  final String uploadBattle;
  final int categoryindex;
  const BattleHomePage(
      {super.key, required this.uploadBattle, required this.categoryindex});

  @override
  State<BattleHomePage> createState() => _BattleHomePageState();
}

class _BattleHomePageState extends State<BattleHomePage> {
  int currentPageIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final _battleupload = Hive.box("BattleUpload");
  final _anotherbattleupload = Hive.box("battledetail");
  final _heartbox = Hive.box("heartBox");

  List<String> Battletitle = [
    '나보다 공부 잘하는 사람',
    '편집 나보 잘함?',
    '저보다 암산력 빠른사람 손',
    '암기력 나보다 좋은 사람 들어오삼',
    '이거 이길 수 있는 사람만 들어와라',
    '이 춤 챌린지 이길 수 있겠어?',
    '달리기 솔직히 내가 제일 빠른듯',
    '몸무게 대결 뜰사람 난 일단 100kg임',
    '나보다 많이 먹는 사람 대결 ㄱㄱ',
    '반응속도 나보다 빠른 사람 있음?',
  ];

  List<String> BattleUploadDataGet(int index) {
    return _battleupload.get(index, defaultValue: <String>[])!.cast<String>();
  }

  Future<void> BattleUploadDelete(int outerIndex, int innerIndex) async {
    // `_battleupload`에서 현재 데이터를 가져옴
    List<String> currentList =
        _battleupload.get(outerIndex, defaultValue: <String>[]).cast<String>();

    // 인덱스 유효성 확인
    if (innerIndex < 0 || innerIndex >= currentList.length) {
      print("innerIndex가 currentList 범위를 벗어났습니다: $innerIndex");
      return; // 잘못된 인덱스라면 종료
    }

    // 해당 아이템 삭제
    currentList.removeAt(innerIndex);
    await _battleupload.put(outerIndex, currentList);

    // `_anotherbattleupload`에서 현재 데이터를 가져옴
    dynamic anotherBattleRaw = _anotherbattleupload.get(
      outerIndex,
      defaultValue: <List<List<String>>>[],
    );

    // 데이터 변환
    List<List<List<String>>> anotherBattleList;
    if (anotherBattleRaw is List &&
        anotherBattleRaw.every((outer) =>
            outer is List && outer.every((inner) => inner is List<String>))) {
      anotherBattleList = anotherBattleRaw
          .map((outer) => (outer as List)
              .map((inner) => (inner as List<String>).toList())
              .toList())
          .toList();
    } else {
      anotherBattleList = <List<List<String>>>[];
    }

    // outerIndex와 innerIndex 범위 확인
    if (outerIndex >= anotherBattleList.length ||
        innerIndex >= anotherBattleList[outerIndex].length) {
      print(
          "범위를 벗어나는 데이터 삭제 시도: outerIndex=$outerIndex, innerIndex=$innerIndex");
      return;
    }

    // 데이터 삭제
    anotherBattleList[outerIndex].removeAt(innerIndex);
    await _anotherbattleupload.put(outerIndex, anotherBattleList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: 40,
            backgroundColor: Colors.green.shade100,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20, bottom: 10),
              title: Padding(
                padding: EdgeInsets.only(right: 60, left: 40),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '검색...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(padding: EdgeInsets.only(top: 10)),
          if (BattleUploadDataGet(widget.categoryindex).isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text('첫 게시물이 되어보아요!'), // 빈 화면에 표시할 내용
              ),
            )
          else
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 500),
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return DetailScreen(
                                  BattleRoomPageindex: index,
                                  categoryindex: widget.categoryindex);
                            },
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var begin = Offset(1.0, 0.0);
                              var end = Offset.zero;
                              var curve = Curves.easeInOut;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 220,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    'assets/user.png',
                                  ),
                                  Positioned(
                                    left: 160,
                                    child: GestureDetector(
                                      onTap: () async {
                                        // outerIndex는 SliverGrid의 index
                                        int outerIndex = widget.categoryindex;

                                        // 내부 리스트에서 index 삭제
                                        await BattleUploadDelete(
                                            outerIndex, index);

                                        // 상태 업데이트
                                        setState(() {});
                                      },
                                      child: Icon(Icons.close),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                BattleUploadDataGet(
                                    widget.categoryindex)[index],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: BattleUploadDataGet(widget.categoryindex).length,
              ),
            ),
        ],
      ),
      floatingActionButton: SpeedDial(
        activeChild: Icon(Icons.close),
        children: [
          SpeedDialChild(
            child: Icon(Icons.camera),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Battleupload(
                    BattleHomePageindex: widget.categoryindex,
                  ),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.picture_in_picture),
          ),
        ],
        child: Icon(Icons.add),
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final int BattleRoomPageindex;
  final int categoryindex;
  const DetailScreen(
      {super.key,
      required this.BattleRoomPageindex,
      required this.categoryindex});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _anotherbattleupload = Hive.box("battledetail");
  final _heartbox = Hive.box("heartBox");
  @override
  List<String> BattleRoomUploadDataGet(int outerIndex, int innerIndex) {
    try {
      // Hive에서 데이터 가져오기
      dynamic rawData = _anotherbattleupload.get(
        outerIndex,
        defaultValue: <List<List<String>>>[],
      );

      // 데이터 구조 초기화 및 타입 확인
      List<List<List<String>>> fullData;

      if (rawData is List &&
          rawData
              .every((e) => e is List && e.every((f) => f is List<String>))) {
        fullData = rawData
            .map((e) =>
                (e as List).map((f) => (f as List<String>).toList()).toList())
            .toList();
      } else {
        fullData = <List<List<String>>>[]; // 기본값 초기화
      }

      // outerIndex 초기화
      while (fullData.length <= outerIndex) {
        fullData.add(<List<String>>[]);
      }

      // innerIndex 초기화
      while (fullData[outerIndex].length <= innerIndex) {
        fullData[outerIndex].add(<String>[]);
      }

      // 유효한 데이터 반환
      return fullData[outerIndex][innerIndex];
    } catch (e, stackTrace) {
      // 오류 발생 시 기본값 반환 및 한국어로 로그 출력
      print("BattleRoomUploadDataGet에서 오류가 발생했습니다: $e");
      print("오류 추적 정보: $stackTrace");
      return <String>[]; // 빈 리스트 반환
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> BattleRoomUploadDelete(
      int outerIndex, int innerIndex, int valueIndex) async {
    // 기존 데이터 가져오기
    dynamic rawData = _anotherbattleupload.get(
      outerIndex,
      defaultValue: <List<List<String>>>[],
    );

    dynamic rawData0 = _heartbox.get(
      outerIndex,
      defaultValue: <List<List<String>>>[],
    );

    // 데이터 구조 초기화 및 타입 확인
    List<List<List<String>>> fullData;
    List<List<List<String>>> fullData0;

    if (rawData is List &&
        rawData.every((e) => e is List && e.every((f) => f is List<String>))) {
      fullData = rawData
          .map((e) =>
              (e as List).map((f) => (f as List<String>).toList()).toList())
          .toList();
    } else {
      fullData = <List<List<String>>>[];
    }

    if (rawData0 is List &&
        rawData0.every((e) => e is List && e.every((f) => f is List<String>))) {
      fullData0 = rawData0
          .map((e) =>
              (e as List).map((f) => (f as List<String>).toList()).toList())
          .toList();
    } else {
      fullData0 = <List<List<String>>>[];
    }

    if (valueIndex < fullData0[outerIndex][innerIndex].length) {
      fullData0[outerIndex][innerIndex].removeAt(valueIndex);

      // innerIndex 레벨이 비어있으면 제거
      if (fullData0[outerIndex][innerIndex].isEmpty) {
        fullData0[outerIndex].removeAt(innerIndex);
      }

      // outerIndex 레벨이 비어있으면 제거
      if (fullData0[outerIndex].isEmpty) {
        fullData0.removeAt(outerIndex);
      }
    }

    // 값 삭제
    if (valueIndex < fullData[outerIndex][innerIndex].length) {
      fullData[outerIndex][innerIndex].removeAt(valueIndex);

      // innerIndex 레벨이 비어있으면 제거
      if (fullData[outerIndex][innerIndex].isEmpty) {
        fullData[outerIndex].removeAt(innerIndex);
      }

      // outerIndex 레벨이 비어있으면 제거
      if (fullData[outerIndex].isEmpty) {
        fullData.removeAt(outerIndex);
      }
    }

    // 변경된 데이터 저장
    await _anotherbattleupload.put(outerIndex, fullData);
    await _heartbox.put(outerIndex, fullData0);
  }

  @override
  Widget build(BuildContext context) {
    // gridIndex를 기반으로 다른 수의 GridView.builder 설정

    return Scaffold(
      appBar: AppBar(
        title: Text('상세 페이지'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 182,
                height: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Image.asset('assets/user.png'),
                    Text('내가 1등 아니면 이상함'),
                  ],
                ),
              ),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: BattleRoomUploadDataGet(
                        widget.categoryindex, widget.BattleRoomPageindex)
                    .length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      print('선택한 것은:$index');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BattleReels(
                            initialIndex: index,
                            categoryindex: widget.categoryindex,
                            detailindex: widget.BattleRoomPageindex,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.asset(
                                  'assets/user.png',
                                ),
                              ),
                              Positioned(
                                left: 145,
                                child: IconButton(
                                  onPressed: () async {
                                    int outerIndex = widget.categoryindex;
                                    int innerIndex = widget.BattleRoomPageindex;
                                    await BattleRoomUploadDelete(
                                        outerIndex, innerIndex, index);
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.close),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            BattleRoomUploadDataGet(widget.categoryindex,
                                widget.BattleRoomPageindex)[index],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SpeedDial(
        children: [
          SpeedDialChild(
            child: Icon(Icons.camera),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BattleRoomUpload(
                    BattleRomePageindex: widget.BattleRoomPageindex,
                    categoryindex: widget.categoryindex,
                  ),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.picture_in_picture),
          ),
        ],
        activeChild: Icon(Icons.close),
        child: Icon(Icons.add),
      ),
    );
  }
}

class BattleReels extends StatefulWidget {
  final int initialIndex;
  final int categoryindex;
  final int detailindex;
  const BattleReels(
      {super.key,
      required this.initialIndex,
      required this.categoryindex,
      required this.detailindex});

  @override
  State<BattleReels> createState() => _BattleReelsState();
}

class _BattleReelsState extends State<BattleReels> {
  final List<String> _comments = [];
  final _heartbox = Hive.box("heartBox");
  final _anotherbattleupload = Hive.box("battledetail");

  final TextEditingController _controller = TextEditingController();

  void updateHeartData(int category, int detailIndex, int valueIndex) {
    // 데이터 가져오기
    dynamic heartDataRaw = _heartbox.get(
      category,
      defaultValue: <List<List<String>>>[], // 빈 데이터 초기화
    );

    // 하트 데이터 초기화 및 타입 변환
    List<List<List<String>>> heartData;

    if (heartDataRaw is List &&
        heartDataRaw.every((outer) =>
            outer is List && outer.every((inner) => inner is List<String>))) {
      heartData = heartDataRaw
          .map((outer) => (outer as List)
              .map((inner) => (inner as List<String>).toList())
              .toList())
          .toList();
    } else {
      heartData = <List<List<String>>>[]; // 기본값 초기화
    }

    // category와 detailIndex 초기화
    while (heartData.length <= category) {
      heartData.add(<List<String>>[]); // 카테고리 추가
    }

    while (heartData[category].length <= detailIndex) {
      heartData[category].add(<String>[]); // 세부 인덱스 추가
    }

    // 하트 상태를 true로 설정
    List<String> heartList = heartData[category][detailIndex];

    // valueIndex에 해당하는 키 값 추가
    while (heartList.length <= valueIndex) {
      heartList.add("false"); // 기본값 추가
    }

    // 상태를 true로 변경
    heartList[valueIndex] = "true";

    // 변경된 데이터를 Hive에 저장
    _heartbox.put(category, heartData);

    print(
        "하트가 활성화되었습니다: category=$category, detailIndex=$detailIndex, valueIndex=$valueIndex");
  }

  void heartDelete(int category, int detailIndex, int valueIndex) {
    // 데이터 가져오기
    dynamic heartDataRaw = _heartbox.get(
      category,
      defaultValue: <List<List<String>>>[], // 빈 데이터 초기화
    );

    // 하트 데이터 초기화 및 타입 변환
    List<List<List<String>>> heartData;

    if (heartDataRaw is List &&
        heartDataRaw.every((outer) =>
            outer is List && outer.every((inner) => inner is List<String>))) {
      heartData = heartDataRaw
          .map((outer) => (outer as List)
              .map((inner) => (inner as List<String>).toList())
              .toList())
          .toList();
    } else {
      heartData = <List<List<String>>>[]; // 기본값 초기화
    }

    // category와 detailIndex 초기화
    while (heartData.length <= category) {
      heartData.add(<List<String>>[]); // 카테고리 추가
    }

    while (heartData[category].length <= detailIndex) {
      heartData[category].add(<String>[]); // 세부 인덱스 추가
    }

    // 하트 상태를 false로 설정
    List<String> heartList = heartData[category][detailIndex];

    // 상태를 false로 변경
    heartList[valueIndex] = "false";

    // 변경된 데이터를 Hive에 저장
    _heartbox.put(category, heartData);

    print(
        "하트가 비활성화되었습니다: category=$category, detailIndex=$detailIndex, valueIndex=$valueIndex");
  }

  void _addComment() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _comments.add(_controller.text); // 입력된 텍스트를 리스트에 추가
      });
      _controller.clear(); // 텍스트필드 초기화
    }
  }

  int reelseindex(int category, int detailindex) {
    // Hive에서 데이터 가져오기
    dynamic rawData = _anotherbattleupload.get(
      category,
      defaultValue: <List<List<String>>>[], // 기본값으로 빈 구조 제공
    );

    // 데이터 초기화 및 타입 변환
    List<List<List<String>>> fullData;

    if (rawData is List &&
        rawData.every((e) => e is List && e.every((f) => f is List<String>))) {
      fullData = rawData
          .map((e) =>
              (e as List).map((f) => (f as List<String>).toList()).toList())
          .toList();
    } else {
      fullData = <List<List<String>>>[]; // 기본값 초기화
    }

    // 인덱스 범위 확인
    if (category >= fullData.length ||
        detailindex >= fullData[category].length) {
      // 범위를 벗어나면 0을 반환
      return 0;
    }

    // 지정된 category와 detailindex의 데이터 가져오기
    List<String> reelseList = fullData[category][detailindex];

    // 리스트의 길이를 반환
    return reelseList.length;
  }

  bool _isLiked(int category, int detailIndex, int valueIndex) {
    dynamic heartDataRaw = _heartbox.get(
      category,
      defaultValue: <List<List<String>>>[], // 기본값 초기화
    );

    // 데이터 초기화 및 타입 확인
    List<List<List<String>>> heartData;

    if (heartDataRaw is List &&
        heartDataRaw.every((outer) =>
            outer is List && outer.every((inner) => inner is List<String>))) {
      heartData = heartDataRaw
          .map((outer) => (outer as List)
              .map((inner) => (inner as List<String>).toList())
              .toList())
          .toList();
    } else {
      return false; // 기본값
    }

    // 범위 확인
    if (category >= heartData.length ||
        detailIndex >= heartData[category].length ||
        valueIndex >= heartData[category][detailIndex].length) {
      return false;
    }

    return heartData[category][detailIndex][valueIndex] == "true";
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController =
        PageController(initialPage: widget.initialIndex);
    return Scaffold(
      appBar: AppBar(
        title: Text('배틀 릴스'),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: pageController,
        scrollDirection: Axis.vertical, // 수직 스크롤 설정
        itemCount:
            reelseindex(widget.categoryindex, widget.detailindex), // 페이지 수
        itemBuilder: (context, index) {
          bool isLiked =
              _isLiked(widget.categoryindex, widget.detailindex, index);
          return Container(
            color: Colors.blue,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/user.png'),
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_isLiked(widget.categoryindex,
                                widget.detailindex, index)) {
                              heartDelete(widget.categoryindex,
                                  widget.detailindex, index);
                            } else {
                              updateHeartData(widget.categoryindex,
                                  widget.detailindex, index);
                            }
                          });
                        },
                        child: Icon(
                          Icons.favorite,
                          color: _isLiked(widget.categoryindex,
                                  widget.detailindex, index)
                              ? Colors.red
                              : Colors.white,
                          size: 40,
                        ),
                      ),
                      Text(
                        '14.7k',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context)
                                          .unfocus(); // 키보드 내리기
                                    },
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.7,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Center(
                                              child: Text(
                                                '댓글 ${_comments.length}개',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: _comments.length,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 16.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          CircleAvatar(
                                                            backgroundImage:
                                                                AssetImage(
                                                                    'assets/user.png'),
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            'User ${index + 1}',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(_comments[index]),
                                                      SizedBox(height: 8),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text('방금 전'),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .favorite_border,
                                                                  size: 16),
                                                              SizedBox(
                                                                  width: 4),
                                                              Text('9'),
                                                              SizedBox(
                                                                  width: 16),
                                                              Icon(
                                                                  Icons.comment,
                                                                  size: 16),
                                                              SizedBox(
                                                                  width: 4),
                                                              Text('답글 1개 보기'),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Divider(),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Divider(),
                                          // 입력창 부분만 패딩 추가
                                          Padding(
                                            padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    controller: _controller,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          '따듯한 말 한마디 해주세요...',
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          Colors.grey.shade200,
                                                      prefixIcon:
                                                          GestureDetector(
                                                        onTap: () {},
                                                        child: Icon(Icons
                                                            .emoji_emotions_outlined),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                GestureDetector(
                                                  onTap: _addComment,
                                                  child: Icon(Icons.send,
                                                      color: Colors.blue),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Icon(
                              Icons.sms,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '4.2k',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: [
                          Icon(
                            Icons.share,
                            size: 40,
                            color: Colors.white,
                          ),
                          Text(
                            '4.2k',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: [
                          Icon(
                            Icons.download,
                            size: 40,
                            color: Colors.white,
                          ),
                          Text(
                            '4.2k',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// class BattleHomePage extends StatefulWidget {
//   final VoidCallback callback;
//   const BattleHomePage({super.key, required this.callback});

//   @override
//   State<BattleHomePage> createState() => _BattleHomePageState();
// }

// class _BattleHomePageState extends State<BattleHomePage> {
//   int currentPageIndex = 0;
//   List<YoutubePlayerController> _controllers = [];

//   @override
//   void initState() {
//     super.initState();
//     // 임의의 유튜브 영상 ID를 리스트로 생성
//     List<String> videoIds = [
//       '6tDcZNa_Q2M', // 예시 영상 ID
//       '6tDcZNa_Q2M', // 다른 예시 영상 ID
//       '6tDcZNa_Q2M', // 다른 예시 영상 ID
//       '6tDcZNa_Q2M', // 다른 예시 영상 ID
//       '6tDcZNa_Q2M', // 다른 예시 영상 ID
//       '6tDcZNa_Q2M', // 다른 예시 영상 ID
//       '6tDcZNa_Q2M', // 다른 예시 영상 ID
//       '6tDcZNa_Q2M', // 다른 예시 영상 ID
//       '6tDcZNa_Q2M', // 다른 예시 영상 ID
//       '6tDcZNa_Q2M', // 다른 예시 영상 ID
//     ];

//     // 각 ID에 대해 컨트롤러 생성
//     _controllers = videoIds
//         .map((videoId) => YoutubePlayerController(
//               initialVideoId: videoId,
//               flags: YoutubePlayerFlags(
//                 autoPlay: false,
//                 mute: false,
//               ),
//             ))
//         .toList();
//   }

//   @override
//   void dispose() {
//     // 모든 컨트롤러 해제
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         SliverAppBar(
//           floating: true,
//           snap: true,
//           expandedHeight: 40,
//           backgroundColor: Colors.green.shade100,
//           flexibleSpace: FlexibleSpaceBar(
//             titlePadding: EdgeInsets.only(left: 20, bottom: 10),
//             title: Padding(
//               padding: EdgeInsets.only(right: 60, left: 40),
//               child: TextField(
//                 decoration: InputDecoration(
//                   hintText: '검색...',
//                   contentPadding: EdgeInsets.symmetric(horizontal: 12),
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide.none,
//                   ),
//                   prefixIcon: Icon(Icons.search),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SliverPadding(padding: EdgeInsets.only(top: 15)),
//         SliverGrid(
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             childAspectRatio: 0.7,
//           ),
//           delegate: SliverChildBuilderDelegate(
//             (context, index) {
//               return Padding(
//                 padding: const EdgeInsets.all(6.0),
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.of(context).push(
//                       PageRouteBuilder(
//                         transitionDuration: Duration(milliseconds: 500),
//                         pageBuilder: (context, animation, secondaryAnimation) {
//                           return DetailScreen();
//                         },
//                         transitionsBuilder:
//                             (context, animation, secondaryAnimation, child) {
//                           var begin = Offset(1.0, 0.0);
//                           var end = Offset.zero;
//                           var curve = Curves.easeInOut;

//                           var tween = Tween(begin: begin, end: end)
//                               .chain(CurveTween(curve: curve));

//                           return SlideTransition(
//                             position: animation.drive(tween),
//                             child: child,
//                           );
//                         },
//                       ),
//                     );
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       color: Colors.white,
//                     ),
//                     child: Column(
//                       children: [
//                         Container(
//                           height: 220,
//                           width: 200,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: YoutubePlayer(
//                             controller:
//                                 _controllers[index % _controllers.length],
//                           ),
//                         ),
//                         Text('어떤 것이 고민인가요?'),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//             childCount: _controllers.length,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class DetailScreen extends StatefulWidget {
//   const DetailScreen({super.key});

//   @override
//   State<DetailScreen> createState() => _DetailScreenState();
// }

// class _DetailScreenState extends State<DetailScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('상세 페이지'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: 182,
//                 height: 230,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   color: Colors.blue,
//                 ),
//               ),
//               SizedBox(height: 10),
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   mainAxisSpacing: 8.0,
//                   crossAxisSpacing: 8.0,
//                   childAspectRatio: 0.8,
//                 ),
//                 itemCount: 10,
//                 itemBuilder: (context, index) {
//                   return GestureDetector(
//                     onTap: () {
//                       print('선택한 것은:$index');
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => BattleReels(
//                             initialIndex: index,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.blue,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
