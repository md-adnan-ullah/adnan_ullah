/// Your bKash number, bank details, and instructions for manual payment.
class SellerConfig {
  // bKash
  static const String bkashNumber = '01783773113';
  static const String bkashInstructionTop = 'Please send to this number';
  static const String bkashInstructionBelow =
      'Send the amount via bKash app, then enter your transaction ID below. We\'ll verify and unlock your download.';

  // Bank
  static const String bankInstructionTop = 'Please send to this account';
  static const String bankName = 'Brac Bank';
  static const String accountName = 'Md. Adnan Ullah';
  static const String accountNumber = '1057655220001';
  static const String branchName = 'Gulshan';
  static const String bankInstructionBelow =
      'Send the amount via bank transfer, then enter your transaction ID below. We\'ll verify and unlock your download.';
}
