import 'package:flutter/material.dart';

class DemoInfoScreen extends StatelessWidget {
  const DemoInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('데모 모드 안내'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildFeaturesCard(),
            const SizedBox(height: 20),
            _buildDemoAccountsCard(),
            const SizedBox(height: 20),
            _buildSetupGuideCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text(
                  '데모 모드로 실행 중',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Firebase 설정이 완료되지 않아 데모 모드로 실행됩니다. '
              '모든 기능을 정상적으로 체험할 수 있지만, 실제 외부 서비스는 연동되지 않습니다.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text(
                  '사용 가능한 기능',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...[
              '✅ 이메일 로그인/회원가입 (데모)',
              '✅ 구글 로그인 (데모 계정)',
              '✅ 네이버 로그인 (데모 계정)',
              '✅ 홈 화면 및 사용자 정보 표시',
              '✅ 로그아웃 기능',
              '✅ 모든 UI 컴포넌트',
            ].map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(feature, style: const TextStyle(fontSize: 14)),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoAccountsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_circle, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  '데모 계정 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '구글/네이버 로그인 시 자동으로 데모 계정이 생성됩니다.\n'
              '이메일 로그인은 어떤 이메일/비밀번호든 입력 가능합니다.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupGuideCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                const Text(
                  '실제 서비스 설정 방법',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '실제 서비스를 사용하려면 다음 설정이 필요합니다:\n\n'
              '1. Firebase 프로젝트 생성 및 설정\n'
              '   - google-services.json (Android)\n'
              '   - GoogleService-Info.plist (iOS)\n\n'
              '2. 구글 로그인 설정\n'
              '   - SHA-1 키 등록\n\n'
              '3. 네이버 로그인 설정\n'
              '   - 네이버 개발자 센터 앱 등록',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}