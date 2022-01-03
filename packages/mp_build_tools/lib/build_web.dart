import 'dart:io';

import 'package:mp_build_tools/i18n.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';

import 'build_plugins.dart' as plugin_builder;

main(List<String> args) {
  print(I18n.building());
  _checkPubspec();
  _createBuildDir();
  _buildDartJS(args);
  plugin_builder.main(args);
  _copyWebSource();
  print(I18n.buildSuccess('build'));
}

_checkPubspec() {
  if (!File('pubspec.yaml').existsSync()) {
    throw I18n.pubspecYamlNotExists();
  }
}

_createBuildDir() {
  if (!Directory('build').existsSync()) {
    Directory('build').createSync();
  } else {
    Directory('build').deleteSync(recursive: true);
    Directory('build').createSync();
  }
}

void _buildDartJS(List<String> args) {
  final dart2JSParams = args.toList();
  if (!dart2JSParams.any((element) => element.startsWith('-O'))) {
    dart2JSParams.add('-O4');
  }
  final dart2JsResult = Process.runSync(
      'dart2js',
      [
        p.join('lib', 'main.dart'),
        ...dart2JSParams,
        '-Ddart.vm.product=true',
        '-Dmpflutter.hostType=browser',
        '-o',
        p.join('build', 'main.dart.js')
      ]..removeWhere((element) => element.isEmpty),
      runInShell: true);
  if (dart2JsResult.exitCode != 0) {
    print(dart2JsResult.stdout);
    print(dart2JsResult.stderr);
    throw I18n.executeFail('dart2js');
  }
  _fixDefererLoader();
  final buildBundleResult = Process.runSync(
    'flutter',
    [
      'build',
      'bundle',
    ],
    runInShell: true,
    environment: {'PUB_HOSTED_URL': 'https://pub.mpflutter.com'},
  );
  if (buildBundleResult.exitCode != 0) {
    print(buildBundleResult.stdout);
    print(buildBundleResult.stderr);
    throw I18n.executeFail('flutter build bundle');
  }
  if (Directory(p.join('build', 'flutter_assets')).existsSync()) {
    Directory(p.join('build', 'flutter_assets'))
        .renameSync(p.join('build', 'assets'));
  }
  _removeFiles([
    p.join('build', 'assets', 'isolate_snapshot_data'),
    p.join('build', 'assets', 'kernel_blob.bin'),
    p.join('build', 'assets', 'vm_snapshot_data'),
    p.join('build', 'assets', 'snapshot_blob.bin.d'),
  ]);
}

_fixDefererLoader() {
  var code = File(p.join('build', 'main.dart.js')).readAsStringSync();
  code = code.replaceAllMapped(RegExp(r"m=\$\.([a-z0-9A-Z]+)\(\)\nm.toString"),
      (match) {
    return "m=\$.${match.group(1)}() || ''\nm.toString";
  });
  code = code.replaceFirst(
      "\$.\$get\$thisScript();", "\$.\$get\$thisScript() || '';");
  File(p.join('build', 'main.dart.js')).writeAsStringSync(code);
}

_copyWebSource() async {
  _copyPathSync(p.join('web'), p.join('build'));
  final mainDartJSHashCode = File(p.join('build', 'main.dart.js')).existsSync()
      ? (await md5.bind(File(p.join('build', 'main.dart.js')).openRead()).first)
          .toString()
          .substring(0, 8)
      : "";
  final pluginMinJSHashCode =
      File(p.join('build', 'plugins.min.js')).existsSync()
          ? (await md5
                  .bind(File(p.join('build', 'plugins.min.js')).openRead())
                  .first)
              .toString()
              .substring(0, 8)
          : "";
  var indexFileContent = File(p.join('web', 'index.html')).readAsStringSync();
  indexFileContent =
      indexFileContent.replaceAll("var dev = true;", "var dev = false;");
  indexFileContent = indexFileContent
      .replaceAll("main.dart.js", "main.dart.js?$mainDartJSHashCode")
      .replaceAll("plugins.min.js", "plugins.min.js?$pluginMinJSHashCode");
  File(p.join('build', 'index.html')).writeAsStringSync(indexFileContent);
}

_removeFiles(List<String> files) {
  files.forEach((element) {
    try {
      File(element).deleteSync();
    } catch (e) {}
  });
}

void _copyPathSync(String from, String to) {
  Directory(to).createSync(recursive: true);
  for (final file in Directory(from).listSync(recursive: true)) {
    final copyTo = p.join(to, p.relative(file.path, from: from));
    if (file is Directory) {
      Directory(copyTo).createSync(recursive: true);
    } else if (file is File) {
      File(file.path).copySync(copyTo);
    } else if (file is Link) {
      Link(copyTo).createSync(file.targetSync(), recursive: true);
    }
  }
}
