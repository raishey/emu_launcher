import 'package:emu_launcher/emu_launcher.dart';
import 'package:emu_launcher/src/messaging/progress_status.dart';
import 'package:emu_launcher/src/connections/ftp_connection.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final awesome = Awesome();

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(awesome.isAwesome, isTrue);
    });
  });

  group('ProgressStatus', () {
    test('should create a progress status that reflects passed parameters',(){
      final status = ProgressStatus(progressMessage:'foo');
      expect( status.progressMessage, equals('foo'));
      expect(status.progressPercentage, isNull);
    });
  });

  group('ftp tests',() {
    test('create a successful mister connection', () async {
        FtpClient client = FtpClient(
            FtpParameters('192.168.5.125', 21, 'root',  '1', null)); 

        Stream<ProgressStatus> list =   client.connect();
        List<ProgressStatus> items = await list.toList();


        expect(items.length, 4);
        expect(items[3].progressMessage, equals('Complete.'));
        expect(items[2].progressMessage, equals('Connected to: MiSTer FPGA'));
    });

test('create a successful retropie connection', () async {
        FtpClient client = FtpClient(
            FtpParameters('sftp://192.168.4.202', null, 'pi',  'raspberry', null)); 

        Stream<ProgressStatus> list =   client.connect();
        List<ProgressStatus> items = await list.toList();


        expect(items.length, 4);
        expect(items[3].progressMessage, equals('Complete.'));
        expect(items[2].progressMessage, equals('Connected to: MiSTer FPGA'));
    });

  });
}
