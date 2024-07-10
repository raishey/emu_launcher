import 'package:dartssh2/dartssh2.dart';
import 'package:emu_launcher/src/messaging/progress_status.dart';
import 'package:ftpconnect/ftpconnect.dart';



class FtpParameters {
    final String host;
    final int? port;
    final String user;
    final String password;
    final String? directory;

    FtpParameters(this.host, this.port, this.user, this.password, this.directory);
}

enum GameConsole {
  mister,
  r36s,
  retroidpro,
  retropie,
  unknown
}

class FtpClient {
    
    final FtpParameters parameters;
    FTPConnect? connection;
    GameConsole? console;

    FtpClient(this.parameters);

    Stream <ProgressStatus> connect() async* {
        int port = parameters.port ?? 21;

        yield ProgressStatus(
            progressMessage: "Connecting to ${parameters.host}:${port}");


        var sshclient = SSHClient(
        await SSHSocket.connect(parameters.host, port),
        username: parameters.user,
        onPasswordRequest: () => parameters.password,
      );

        var conn = FTPConnect(parameters.host, port: port, user: parameters.user, pass: parameters.password, showLog:false), securityType = SecurityType.FTPS;
        
        var connected = await conn.connect();


        if(!connected) {
            yield ProgressStatus(progressMessage: "Failed to connect.");
            return;
        }
        yield ProgressStatus(progressMessage: 'Identifying Host...');
        //await Future.delayed(Duration(seconds: 1));


        yield* identify(conn);


        yield ProgressStatus(progressMessage: "Complete.", progressPercentage: 100);
        connection=conn;
    }

    Stream<ProgressStatus> identify(FTPConnect conn)  async* {
      

      if (await isMisterFPGA(conn)) {
        console = GameConsole.mister;
        yield ProgressStatus(
            progressMessage: "Connected to: MiSTer FPGA");
        return;
      }

      if(await isRetroPie(conn)){
        console = GameConsole.retropie;
        yield ProgressStatus(
            progressMessage: "Connected to: RetroPie");
        return;
      }


      console = GameConsole.unknown;
    }

   Future<bool> isMisterFPGA(FTPConnect conn) async {
      return await conn.existFile('/MiSTer.version');
    }

    Future<bool> isRetroPie(FTPConnect conn)  async  {
      return await conn.existFile('/opt/retropie/VERSION');
    }
}