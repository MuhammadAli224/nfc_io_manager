import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCScreen extends StatefulWidget {
  const NFCScreen({super.key});

  @override
  State<StatefulWidget> createState() => _NFCScreenState();
}

class _NFCScreenState extends State<NFCScreen> {
  ValueNotifier<dynamic> result = ValueNotifier(null);
  TextEditingController dataText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NfcManager IO ')),
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: NfcManager.instance.isAvailable(),
          builder: (context, ss) => ss.data != true
              ? Center(child: Text('NfcManager.isAvailable(): ${ss.data}'))
              : Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Flex(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    direction: Axis.vertical,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          constraints: const BoxConstraints.expand(),
                          decoration: BoxDecoration(border: Border.all()),
                          child: SingleChildScrollView(
                            child: ValueListenableBuilder<dynamic>(
                              valueListenable: result,
                              builder: (context, value, _) =>
                                  Text('${value ?? ''}'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: dataText,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter The Data you need write into NFC",
                        ),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        flex: 3,
                        child: GridView.count(
                          padding: const EdgeInsets.all(4),
                          crossAxisCount: 2,
                          childAspectRatio: 3.5,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 10,
                          children: [
                            ElevatedButton(
                                onPressed: _tagRead,
                                child: const Text('Tag Read')),
                            ElevatedButton(
                                onPressed: _ndefWriteLock,
                                child: const Text('Clear Data')),
                            ElevatedButton(
                                onPressed: () => _ndefWrite('text'),
                                child: const Text('Write As Website')),
                            ElevatedButton(
                                onPressed: () => _ndefWrite('website'),
                                child: const Text('Write As Text')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _ndefWrite(String dataType) {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        result.value = 'Tag is not ndef writable';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }
      NdefRecord ndefRecord = dataType == 'text'
          ? NdefRecord.createUri(Uri.parse(dataText.text.trim()))
          : NdefRecord.createText(dataText.text.trim());
      NdefMessage message = NdefMessage([ndefRecord]);

      try {
        await ndef.write(message);
        result.value = 'Success to "Ndef Write"';
        // NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        // NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }

  void _ndefWriteLock() {
    // NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
    //   var ndef = Ndef.from(tag);
    //   if (ndef == null) {
    //     result.value = 'Tag is not ndef';
    //     // NfcManager.instance.stopSession(errorMessage: result.value.toString());
    //     return;
    //   }
    //
    //   try {
    //     await ndef.writeLock();
    //     result.value = 'Success to "Ndef Write Lock"';
    //     NfcManager.instance.stopSession();
    //   } catch (e) {
    //     result.value = e;
    //     NfcManager.instance.stopSession(errorMessage: result.value.toString());
    //     return;
    //   }
    // });
  }

  void _tagRead() {
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        result.value = tag.data;
        NfcManager.instance.stopSession();
      },
    );
  }
}
