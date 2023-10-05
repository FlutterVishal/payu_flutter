import 'package:flutter/material.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import 'dart:convert';
//Dont Use this file and do the hash calculation in backend.


import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements PayUCheckoutProProtocol {
  
  late PayUCheckoutProFlutter _checkoutPro;

  @override
  void initState() {
    super.initState();
      _checkoutPro = PayUCheckoutProFlutter(this);
  }

   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PayU Checkout Pro'),
        ),
        body: Center(
          child: ElevatedButton(
            child: const Text("Start Payment"),
            onPressed: () async {
              _checkoutPro.openCheckoutScreen(
                payUPaymentParams: PayUParams.createPayUPaymentParams(),
                payUCheckoutProConfig: PayUParams.createPayUConfigParams(),
              );
            },
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, String title, String content) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: new Text(content),
            ),
            actions: [okButton],
          );
        });
  }

  @override
  generateHash(Map response) {
    // Backend will generate the hash which you need to pass to SDK
    // hashResponse: is the response which you get from your server

    Map hashResponse = {};

    //Keep the salt and hash calculation logic in the backend for security reasons. Don't use local hash logic. 
    //Uncomment following line to test the test hash.  
    hashResponse = HashService.generateHash(response);
    
    _checkoutPro.hashGenerated(hash: hashResponse);
  }

  @override
  onPaymentSuccess(dynamic response) {
    showAlertDialog(context, "onPaymentSuccess", response.toString());
  }

  @override
  onPaymentFailure(dynamic response) {
    showAlertDialog(context, "onPaymentFailure", response.toString());
  }

  @override
  onPaymentCancel(Map? response) {
    showAlertDialog(context, "onPaymentCancel", response.toString());
  }

  @override
  onError(Map? response) {
    showAlertDialog(context, "onError", response.toString());
  }
}




class PayUParams {
  static Map createPayUPaymentParams(

      ) {
    var siParams = {
      PayUSIParamsKeys.isFreeTrial: true,
      PayUSIParamsKeys.billingAmount: '1',
      //Required
      PayUSIParamsKeys.billingInterval: 1,
      //Required
      PayUSIParamsKeys.paymentStartDate: DateTime.now().toString(),
      //Required
      PayUSIParamsKeys.paymentEndDate: '2023-04-30',
      //Required
      PayUSIParamsKeys.billingCycle: //Required
      'daily',
      //Can be any of 'daily','weekly','yearly','adhoc','once','monthly'
      PayUSIParamsKeys.remarks: 'Test SI transaction',
      PayUSIParamsKeys.billingCurrency: 'INR',
      PayUSIParamsKeys.billingLimit: 'ON',
      //ON, BEFORE, AFTER
      PayUSIParamsKeys.billingRule: 'MAX',
      //MAX, EXACT
    };

    var additionalParam = {
      PayUAdditionalParamKeys.udf1: "udf1",
      PayUAdditionalParamKeys.udf2: "udf2",
      PayUAdditionalParamKeys.udf3: "udf3",
      PayUAdditionalParamKeys.udf4: "udf4",
      PayUAdditionalParamKeys.udf5: "udf5",
      PayUAdditionalParamKeys.merchantAccessKey:
      PayUTestCredentials.merchantAccessKey,
      PayUAdditionalParamKeys.sourceId: PayUTestCredentials.sodexoSourceId,
    };


    var spitPaymentDetails = {
      "type": "absolute",
      "splitInfo": {
        PayUTestCredentials.merchantKey: {
          "aggregatorSubTxnId": "1234567540099887766650092",
          //unique for each transaction
          "aggregatorSubAmt": "1"
        },
        /* "qOoYIv": {
          "aggregatorSubTxnId": "12345678",
          "aggregatorSubAmt": "40"
       },*/
      }
    };

    var payUPaymentParams = {
      PayUPaymentParamKey.key: PayUTestCredentials.merchantKey,
      PayUPaymentParamKey.amount: 2,
      PayUPaymentParamKey.productInfo: "productInfo",
      PayUPaymentParamKey.firstName: "firstName",
      PayUPaymentParamKey.email:" email",
      PayUPaymentParamKey.phone: 7812625317,
      PayUPaymentParamKey.ios_surl: PayUTestCredentials.iosSurl,
      PayUPaymentParamKey.ios_furl: PayUTestCredentials.iosFurl,
      PayUPaymentParamKey.android_surl: PayUTestCredentials.androidSurl,
      PayUPaymentParamKey.android_furl: PayUTestCredentials.androidFurl,
      PayUPaymentParamKey.environment: "1",
      //0 => Production 1 => Test
      PayUPaymentParamKey.userCredential: "email",
      //TODO: Pass user credential to fetch saved cards => A:B - Optional
      PayUPaymentParamKey.transactionId:
      DateTime.now().millisecondsSinceEpoch.toString(),
      PayUPaymentParamKey.additionalParam: additionalParam,
      PayUPaymentParamKey.enableNativeOTP: true,
      // PayUPaymentParamKey.splitPaymentDetails:json.encode(spitPaymentDetails),
      PayUPaymentParamKey.userToken: "userToken",
      //TODO: Pass a unique token to fetch offers. - Optional
    };
    return payUPaymentParams;
  }

  static Map createPayUConfigParams() {
    var paymentModesOrder = [
      {"Wallets": "PHONEPE"},
      {"UPI": "TEZ"},
      {"Wallets": ""},
      {"EMI": ""},
      {"NetBanking": ""},
    ];

    var cartDetails = [
      {"Unit Price": "unitPrice"},
      {"GST": "gstPercentage"},
      {"Discount Price": "discountPrice"},
    ];
    var enforcePaymentList = [
      {"payment_type": "CARD", "enforce_ibiboCode": "UTIBENCC"},
    ];

    var customNotes = [
      {
        "custom_note": "customNote",
        "custom_note_category": [
          PayUPaymentTypeKeys.emi,
          PayUPaymentTypeKeys.card
        ]
      },
      {
        "custom_note": "Payment options custom note",
        "custom_note_category": null
      }
    ];

    var payUCheckoutProConfig = {
      PayUCheckoutProConfigKeys.primaryColor: '#e7241b',
      PayUCheckoutProConfigKeys.secondaryColor: "#FFFFFF",
      PayUCheckoutProConfigKeys.merchantName: "StudentKare B2B",
      PayUCheckoutProConfigKeys.merchantLogo: "logo",
      PayUCheckoutProConfigKeys.showExitConfirmationOnCheckoutScreen: true,
      PayUCheckoutProConfigKeys.showExitConfirmationOnPaymentScreen: true,
      PayUCheckoutProConfigKeys.cartDetails: cartDetails,
      //PayUCheckoutProConfigKeys.enforcePaymentList: enforcePaymentList,
      PayUCheckoutProConfigKeys.paymentModesOrder: paymentModesOrder,
      PayUCheckoutProConfigKeys.merchantResponseTimeout: 30000,
      PayUCheckoutProConfigKeys.customNotes: customNotes,
      PayUCheckoutProConfigKeys.autoSelectOtp: true,
      PayUCheckoutProConfigKeys.waitingTime: 30000,
      PayUCheckoutProConfigKeys.autoApprove: true,
      PayUCheckoutProConfigKeys.merchantSMSPermission: true,
      PayUCheckoutProConfigKeys.showCbToolbar: true,
    };
    return payUCheckoutProConfig;
  }
}

class PayUTestCredentials {
  static const merchantKey = "oZ7oo9"; //TODO: Add Merchant Key
  //Use your success and fail URL's.

  static const iosSurl =
      "https://payu.herokuapp.com/ios_success"; //TODO: Add Success URL.
  static const iosFurl =
      "https://payu.herokuapp.com/ios_failure"; //TODO Add Fail URL.
  static const androidSurl =
      "https://payu.herokuapp.com/success"; //TODO: Add Success URL.
  static const androidFurl =
      "https://payu.herokuapp.com/failure"; //TODO Add Fail URL.

  static const merchantAccessKey =
      ""; //TODO: Add Merchant Access Key - Optional
  static const sodexoSourceId = ""; //TODO: Add sodexo Source Id - Optional
}

class HashService {
  static const merchantSalt = "UkojH5TS"; // Add you Salt here.
  static const merchantSecretKey = "oZ7oo9"; // Add Merchant Secrete Key - Optional

  static Map generateHash(Map response) {
    var hashName = response[PayUHashConstantsKeys.hashName];
    var hashStringWithoutSalt = response[PayUHashConstantsKeys.hashString];
    var hashType = response[PayUHashConstantsKeys.hashType];
    var postSalt = response[PayUHashConstantsKeys.postSalt];

    var hash = '';

    if (hashType == PayUHashConstantsKeys.hashVersionV2) {
      hash = getHmacSHA256Hash(hashStringWithoutSalt, merchantSalt);
    } else if (hashName == PayUHashConstantsKeys.mcpLookup) {
      hash = getHmacSHA1Hash(hashStringWithoutSalt, merchantSecretKey);
    } else {
      var hashDataWithSalt = hashStringWithoutSalt + merchantSalt;
      if (postSalt != null) {
        hashDataWithSalt = hashDataWithSalt + postSalt;
      }
      hash = getSHA512Hash(hashDataWithSalt);
    }
    //Don't use this method, get the hash from your backend.
    var finalHash = {hashName: hash};
    return finalHash;
  }

  //Don't use this method get the hash from your backend.
  static String getSHA512Hash(String hashData) {
    var bytes = utf8.encode(hashData); // data being hashed
    var hash = sha512.convert(bytes);
    debugPrint("getSHA512Hash:--$hash");

    return hash.toString();
  }

  //Don't use this method get the hash from your backend.
  static String getHmacSHA256Hash(String hashData, String salt) {
    var key = utf8.encode(salt);
    var bytes = utf8.encode(hashData);
    final hmacSha256 = Hmac(sha256, key).convert(bytes).bytes;
    final hmacBase64 = base64Encode(hmacSha256);
    debugPrint("getHmacSHA256Hash:--$hmacBase64");
    return hmacBase64;
  }

  static String getHmacSHA1Hash(String hashData, String salt) {
    var key = utf8.encode(salt);
    var bytes = utf8.encode(hashData);
    var hmacSha1 = Hmac(sha1, key); // HMAC-SHA1
    var hash = hmacSha1.convert(bytes);
    debugPrint("getHmacSHA1Hash:--$hash");
    return hash.toString();
  }
}

class PayUConstants {
  static const payUPaymentParams = "payUPaymentParams";
  static const payUCheckoutProConfig = "payUCheckoutProConfig";
  //Callback handling, Method channel name
  static const onPaymentSuccess = "onPaymentSuccess";
  static const onPaymentFailure = "onPaymentFailure";
  static const onPaymentCancel = "onPaymentCancel";
  static const onError = "onError";
  static const generateHash = "generateHash";
  static const errorMsg = "errorMsg";
  static const errorCode = "errorCode";
  static const isTxnInitiated = "isTxnInitiated";
}

class PayUHashConstantsKeys {
  static const hashName = "hashName";
  static const hashString = "hashString";
  static const hashType = "hashType";
  static const hashVersionV1 = "V1";
  static const hashVersionV2 = "V2";
  static const mcpLookup = "mcpLookup";
  static const postSalt = "postSalt";
}

//Payment request keys ------
class PayUPaymentParamKey {
  static const key = "key";
  static const amount = "amount";
  static const productInfo = "productInfo";
  static const firstName = "firstName";
  static const email = "email";
  static const phone = "phone";
  static const ios_surl = "ios_surl";
  static const ios_furl = "ios_furl";
  static const android_surl = "android_surl";
  static const android_furl = "android_furl";
  static const environment = "environment";
  static const userCredential = "userCredential";
  static const transactionId = "transactionId";
  static const additionalParam = "additionalParam";
  static const payUSIParams = "payUSIParams";
  static const splitPaymentDetails = "splitPaymentDetails";
  static const enableNativeOTP = "enableNativeOTP";
  static const userToken = "userToken"; //Offers user token -
}

class PayUSIParamsKeys {
  static const isFreeTrial = "isFreeTrial";
  static const billingAmount = "billingAmount";
  static const billingInterval = "billingInterval";
  static const paymentStartDate = "paymentStartDate";
  static const paymentEndDate = "paymentEndDate";
  static const billingCycle = "billingCycle";
  static const remarks = "remarks";
  static const billingCurrency = "billingCurrency";
  static const billingLimit = "billingLimit";
  static const billingRule = "billingRule";
}

class PayUUserCredentialsParamKeys {
  static const userName = "userName";
}

class PayUAdditionalParamKeys {
  static const udf1 = "udf1";
  static const udf2 = "udf2";
  static const udf3 = "udf3";
  static const udf4 = "udf4";
  static const udf5 = "udf5";
  static const hash = "hash";
  static const merchantAccessKey = "merchantAccessKey";
  static const sourceId = "sourceId"; //Sodexo source ID
}

class PayUCheckoutProConfigKeys {
  static const primaryColor = "primaryColor";
  static const secondaryColor = "secondaryColor";
  static const merchantName = "merchantName";
  static const merchantLogo = "merchantLogo";
  static const showExitConfirmationOnCheckoutScreen =
      "showExitConfirmationOnCheckoutScreen";
  static const showExitConfirmationOnPaymentScreen =
      "showExitConfirmationOnPaymentScreen";
  static const cartDetails = "cartDetails";
  static const paymentModesOrder = "paymentModesOrder";
  static const merchantResponseTimeout = "merchantResponseTimeout";
  static const customNotes = "customNotes";
  static const autoSelectOtp = "autoSelectOtp";
  static const enforcePaymentList = "enforcePaymentList";

  static const waitingTime = "waitingTime"; //-->(Android)
  static const autoApprove = "autoApprove"; //-->(Android)
  static const merchantSMSPermission = "merchantSMSPermission"; //-->(Android)
  static const showCbToolbar = "showCbToolbar"; //-->(Android)
}


class PayUPaymentTypeKeys {

  static const card =  "CARD";
  static const nb =  "NB";
  static const upi =  "UPI";
  static const upiIntent =  "UPI_INTENT";
  static const wallet =  "WALLET";
  static const emi =  "EMI";
  static const neftRtgs =  "NEFTRTGS";
  static const l1Option =  "L1_OPTION";
  static const sodexo =  "SODEXO";
}
