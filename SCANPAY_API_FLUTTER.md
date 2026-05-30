# ScanPay — Référence API pour Flutter

> Ce document décrit tous les modèles, endpoints, et structures de données du backend ScanPay.
> À utiliser pour créer les models Dart, les repositories et l'affichage des données dans Flutter.

---

## Configuration de base

```
Base URL (dev)  : http://localhost:3000/api/v1
Base URL (prod) : https://your-domain.com/api/v1
Auth            : Bearer Token (JWT)
Content-Type    : application/json
```

---

## Authentification

### POST `/auth/register`

**Body :**
```json
{
  "phone": "+22961000000",
  "firstName": "Jean",
  "lastName": "Dupont",
  "password": "motdepasse123",
  "email": "jean@example.com",       // optionnel
  "role": "client"                    // "client" | "merchant" | "admin"
}
```

**Réponse 201 :**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "phone": "+22961000000",
    "firstName": "Jean",
    "lastName": "Dupont",
    "email": "jean@example.com",
    "role": "client",
    "status": "active",
    "isPhoneVerified": false,
    "avatarUrl": null,
    "fcmToken": null,
    "createdAt": "2026-05-24T08:00:00.000Z",
    "updatedAt": "2026-05-24T08:00:00.000Z"
  }
}
```

---

### POST `/auth/login`

**Body :**
```json
{
  "phone": "+22961000000",
  "password": "motdepasse123"
}
```

**Réponse 200 :** *(même structure que register)*

---

### GET `/auth/me` 🔒

**Réponse 200 :** *(objet User complet)*

---

## Modèle Dart — `UserModel`

```dart
enum UserRole { merchant, client, admin }
enum UserStatus { active, inactive, suspended }

class UserModel {
  final String id;
  final String phone;
  final String firstName;
  final String lastName;
  final String? email;
  final UserRole role;
  final UserStatus status;
  final bool isPhoneVerified;
  final String? avatarUrl;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Getter utile pour l'affichage
  String get fullName => '$firstName $lastName';
  bool get isMerchant => role == UserRole.merchant;

  const UserModel({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.email,
    required this.role,
    required this.status,
    required this.isPhoneVerified,
    this.avatarUrl,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['phone'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.client,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UserStatus.active,
      ),
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      avatarUrl: json['avatarUrl'],
      fcmToken: json['fcmToken'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': phone,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'role': role.name,
    'status': status.name,
    'isPhoneVerified': isPhoneVerified,
    'avatarUrl': avatarUrl,
    'fcmToken': fcmToken,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
```

---

## Modèle Dart — `AuthResponse`

```dart
class AuthResponse {
  final String accessToken;
  final UserModel user;

  const AuthResponse({
    required this.accessToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      user: UserModel.fromJson(json['user']),
    );
  }
}
```

---

## Wallets

### POST `/wallets` 🔒

**Body :**
```json
{
  "provider": "mtn_momo",       // "mtn_momo" | "moov_money" | "celtiis_cash"
  "phoneNumber": "+22961000000",
  "currency": "XOF",            // "XOF" | "EUR" | "USD" — défaut: "XOF"
  "isDefault": true             // optionnel
}
```

**Réponse 201 :** *(objet Wallet)*

---

### GET `/wallets` 🔒
Liste tous mes wallets. Le wallet par défaut est toujours en premier.

### GET `/wallets/:id` 🔒
Détail d'un wallet.

### PATCH `/wallets/:id` 🔒

**Body :**
```json
{
  "isDefault": true,
  "currency": "XOF",
  "status": "active"    // "active" | "suspended"
}
```

### PATCH `/wallets/:id/set-default` 🔒
Définir ce wallet comme défaut.

### DELETE `/wallets/:id` 🔒
Supprimer un wallet.

---

## Modèle Dart — `WalletModel`

```dart
enum WalletProvider { mtn_momo, moov_money, celtiis_cash }
enum WalletCurrency { XOF, EUR, USD }
enum WalletStatus { active, suspended }

class WalletModel {
  final String id;
  final String userId;
  final WalletProvider provider;
  final String phoneNumber;
  final WalletCurrency currency;
  final double balance;
  final bool isDefault;
  final WalletStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Getters utiles pour l'affichage
  String get providerName {
    switch (provider) {
      case WalletProvider.mtn_momo:   return 'MTN Mobile Money';
      case WalletProvider.moov_money: return 'Moov Money';
      case WalletProvider.celtiis_cash: return 'Celtiis Cash';
    }
  }

  String get providerLogo {
    switch (provider) {
      case WalletProvider.mtn_momo:   return 'assets/logos/mtn.png';
      case WalletProvider.moov_money: return 'assets/logos/moov.png';
      case WalletProvider.celtiis_cash: return 'assets/logos/celtiis.png';
    }
  }

  String get formattedBalance => '${balance.toStringAsFixed(0)} ${currency.name}';

  const WalletModel({
    required this.id,
    required this.userId,
    required this.provider,
    required this.phoneNumber,
    required this.currency,
    required this.balance,
    required this.isDefault,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'],
      userId: json['userId'],
      provider: WalletProvider.values.firstWhere(
        (e) => e.name == json['provider'],
      ),
      phoneNumber: json['phoneNumber'],
      currency: WalletCurrency.values.firstWhere(
        (e) => e.name == json['currency'],
        orElse: () => WalletCurrency.XOF,
      ),
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      isDefault: json['isDefault'] ?? false,
      status: WalletStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WalletStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'provider': provider.name,
    'phoneNumber': phoneNumber,
    'currency': currency.name,
    'balance': balance,
    'isDefault': isDefault,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
```

---

## QR Codes

### POST `/qrcodes` 🔒

**Body :**
```json
{
  "amount": 5000,
  "currency": "XOF",
  "walletId": "uuid-wallet",        // optionnel — défaut: wallet par défaut
  "description": "Repas du midi",   // optionnel
  "expiresInMinutes": 15            // optionnel — min:1, max:60, défaut:15
}
```

**Réponse 201 :** *(objet QrCode avec qrImage en base64)*

---

### GET `/qrcodes` 🔒
Liste tous mes QR codes (marchand).

### GET `/qrcodes/scan/:reference`🔒
Récupérer les infos d'un QR code par sa référence (après scan).
- Ex: `GET /qrcodes/scan/SPY-20260524-A3F9`

### GET `/qrcodes/:id` 🔒
Détail d'un QR code.

### PATCH `/qrcodes/:id/cancel` 🔒
Annuler un QR code (status doit être `pending`).

---

## Modèle Dart — `QrCodeModel`

```dart
enum QrCodeStatus { pending, scanned, completed, expired, cancelled }
enum QrCodeCurrency { XOF, EUR, USD }

class QrCodeModel {
  final String id;
  final String merchantId;
  final String? walletId;
  final double amount;
  final QrCodeCurrency currency;
  final String reference;
  final String qrData;
  final String? qrImage;       // base64 PNG — afficher avec Image.memory()
  final QrCodeStatus status;
  final String? description;
  final int expiresInMinutes;
  final DateTime expiresAt;
  final DateTime? scannedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Getters utiles
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => status == QrCodeStatus.pending && !isExpired;

  Duration get remainingTime => expiresAt.difference(DateTime.now());

  String get formattedAmount => '${amount.toStringAsFixed(0)} ${currency.name}';

  String get statusLabel {
    switch (status) {
      case QrCodeStatus.pending:   return 'En attente';
      case QrCodeStatus.scanned:   return 'Scanné';
      case QrCodeStatus.completed: return 'Payé';
      case QrCodeStatus.expired:   return 'Expiré';
      case QrCodeStatus.cancelled: return 'Annulé';
    }
  }

  // Pour afficher l'image QR dans Flutter :
  // Image.memory(base64Decode(qrImage!.split(',').last))

  const QrCodeModel({
    required this.id,
    required this.merchantId,
    this.walletId,
    required this.amount,
    required this.currency,
    required this.reference,
    required this.qrData,
    this.qrImage,
    required this.status,
    this.description,
    required this.expiresInMinutes,
    required this.expiresAt,
    this.scannedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QrCodeModel.fromJson(Map<String, dynamic> json) {
    return QrCodeModel(
      id: json['id'],
      merchantId: json['merchantId'],
      walletId: json['walletId'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      currency: QrCodeCurrency.values.firstWhere(
        (e) => e.name == json['currency'],
        orElse: () => QrCodeCurrency.XOF,
      ),
      reference: json['reference'],
      qrData: json['qrData'],
      qrImage: json['qrImage'],
      status: QrCodeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => QrCodeStatus.pending,
      ),
      description: json['description'],
      expiresInMinutes: json['expiresInMinutes'] ?? 15,
      expiresAt: DateTime.parse(json['expiresAt']),
      scannedAt: json['scannedAt'] != null ? DateTime.parse(json['scannedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
```

---

## Transactions

### POST `/transactions` 🔒
Le client initie le paiement après avoir scanné un QR code.

**Body :**
```json
{
  "qrReference": "SPY-20260524-A3F9",
  "senderWalletId": "uuid-wallet-client"
}
```

**Réponse 201 :** *(objet Transaction avec status: "processing")*

---

### GET `/transactions` 🔒
Liste toutes mes transactions (envoyées + reçues).

**Query params optionnels :**
```
?status=success         // pending | processing | success | failed | refunded
?type=payment           // payment | refund
?from=2026-01-01
?to=2026-12-31
```

### GET `/transactions/stats` 🔒
Stats pour le dashboard marchand.

**Réponse 200 :**
```json
{
  "totalRevenue": 125000,
  "todayTransactions": 5,
  "successfulTransactions": 48
}
```

### GET `/transactions/:id` 🔒
Détail d'une transaction.

### GET `/transactions/ref/:reference` 🔒
Récupérer une transaction par sa référence.
- Ex: `GET /transactions/ref/TXN-20260524-AB12CD`

---

## Modèle Dart — `TransactionModel`

```dart
enum TransactionStatus { pending, processing, success, failed, refunded }
enum TransactionType { payment, refund }

class TransactionModel {
  final String id;
  final String? qrCodeId;
  final String? senderId;
  final String? receiverId;
  final String? senderWalletId;
  final String? receiverWalletId;
  final double amount;
  final double fees;
  final double amountReceived;
  final String currency;
  final TransactionStatus status;
  final TransactionType type;
  final String reference;
  final String? externalReference;
  final String? provider;
  final String? failureReason;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations (présentes si chargées)
  final WalletModel? senderWallet;
  final WalletModel? receiverWallet;
  final QrCodeModel? qrCode;

  // Getters utiles
  String get formattedAmount => '${amount.toStringAsFixed(0)} $currency';
  String get formattedFees => '${fees.toStringAsFixed(0)} $currency';
  String get formattedAmountReceived => '${amountReceived.toStringAsFixed(0)} $currency';

  bool get isSuccess => status == TransactionStatus.success;
  bool get isFailed  => status == TransactionStatus.failed;
  bool get isPending => status == TransactionStatus.pending
                     || status == TransactionStatus.processing;

  String get statusLabel {
    switch (status) {
      case TransactionStatus.pending:    return 'En attente';
      case TransactionStatus.processing: return 'En cours';
      case TransactionStatus.success:    return 'Réussi';
      case TransactionStatus.failed:     return 'Échoué';
      case TransactionStatus.refunded:   return 'Remboursé';
    }
  }

  // Couleur selon le statut — à utiliser dans les widgets
  // success  → Color(0xFF1B5E5E)  vert ScanPay
  // failed   → Colors.red
  // pending  → Color(0xFFF5B800)  or ScanPay
  // refunded → Colors.purple

  const TransactionModel({
    required this.id,
    this.qrCodeId,
    this.senderId,
    this.receiverId,
    this.senderWalletId,
    this.receiverWalletId,
    required this.amount,
    required this.fees,
    required this.amountReceived,
    required this.currency,
    required this.status,
    required this.type,
    required this.reference,
    this.externalReference,
    this.provider,
    this.failureReason,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.senderWallet,
    this.receiverWallet,
    this.qrCode,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      qrCodeId: json['qrCodeId'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      senderWalletId: json['senderWalletId'],
      receiverWalletId: json['receiverWalletId'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      fees: double.tryParse(json['fees'].toString()) ?? 0.0,
      amountReceived: double.tryParse(json['amountReceived'].toString()) ?? 0.0,
      currency: json['currency'] ?? 'XOF',
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.payment,
      ),
      reference: json['reference'],
      externalReference: json['externalReference'],
      provider: json['provider'],
      failureReason: json['failureReason'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      senderWallet: json['senderWallet'] != null
          ? WalletModel.fromJson(json['senderWallet'])
          : null,
      receiverWallet: json['receiverWallet'] != null
          ? WalletModel.fromJson(json['receiverWallet'])
          : null,
      qrCode: json['qrCode'] != null
          ? QrCodeModel.fromJson(json['qrCode'])
          : null,
    );
  }
}
```

---

## Modèle Dart — `MerchantStats`

```dart
class MerchantStats {
  final double totalRevenue;
  final int todayTransactions;
  final int successfulTransactions;

  String get formattedRevenue => '${totalRevenue.toStringAsFixed(0)} XOF';

  const MerchantStats({
    required this.totalRevenue,
    required this.todayTransactions,
    required this.successfulTransactions,
  });

  factory MerchantStats.fromJson(Map<String, dynamic> json) {
    return MerchantStats(
      totalRevenue: double.tryParse(json['totalRevenue'].toString()) ?? 0.0,
      todayTransactions: json['todayTransactions'] ?? 0,
      successfulTransactions: json['successfulTransactions'] ?? 0,
    );
  }
}
```

---

## Gestion des erreurs API

Toutes les erreurs suivent ce format :

```json
{
  "statusCode": 400,
  "message": "Ce QR code a expiré",
  "error": "Bad Request"
}
```

**Modèle Dart — `ApiError` :**

```dart
class ApiError {
  final int statusCode;
  final dynamic message; // String ou List<String>
  final String? error;

  const ApiError({
    required this.statusCode,
    required this.message,
    this.error,
  });

  // Message lisible pour l'utilisateur
  String get displayMessage {
    if (message is List) return (message as List).join(', ');
    return message.toString();
  }

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      statusCode: json['statusCode'] ?? 500,
      message: json['message'] ?? 'Erreur inconnue',
      error: json['error'],
    );
  }
}
```

**Codes HTTP courants :**

| Code | Signification |
|------|---------------|
| 200 | Succès |
| 201 | Créé avec succès |
| 204 | Supprimé (pas de body) |
| 400 | Données invalides / logique métier |
| 401 | Token manquant ou expiré |
| 403 | Accès interdit |
| 404 | Ressource introuvable |
| 409 | Conflit (ex: wallet déjà existant) |
| 500 | Erreur serveur |

---

## Notes d'affichage importantes

### Image QR code
```dart
// qrImage est une data URL base64 : "data:image/png;base64,iVBOR..."
Image.memory(
  base64Decode(qrCode.qrImage!.split(',').last),
  width: 250,
  height: 250,
)
```

### Timer d'expiration QR
```dart
// Afficher le temps restant en temps réel avec un StreamBuilder
final remaining = qrCode.expiresAt.difference(DateTime.now());
final minutes = remaining.inMinutes;
final seconds = remaining.inSeconds % 60;
// Afficher : "14:32"
```

### Couleurs selon statut transaction
```dart
Color transactionColor(TransactionStatus status) {
  switch (status) {
    case TransactionStatus.success:    return const Color(0xFF1B5E5E);
    case TransactionStatus.failed:     return Colors.red;
    case TransactionStatus.pending:
    case TransactionStatus.processing: return const Color(0xFFF5B800);
    case TransactionStatus.refunded:   return Colors.purple;
  }
}
```

### Provider mobile money
```dart
String providerDisplayName(String provider) {
  switch (provider) {
    case 'mtn_momo':    return 'MTN Mobile Money';
    case 'moov_money':  return 'Moov Money';
    case 'celtiis_cash': return 'Celtiis Cash';
    default: return provider;
  }
}
```

---

## Headers requis pour chaque requête authentifiée

```dart
Map<String, String> authHeaders(String token) => {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $token',
};
```
