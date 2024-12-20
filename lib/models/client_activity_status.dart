enum ClientActivityStatus {
  active,
  semiActive,
  inactive;

  String get displayName {
    switch (this) {
      case ClientActivityStatus.active:
        return 'Active';
      case ClientActivityStatus.semiActive:
        return 'Semi-Active';
      case ClientActivityStatus.inactive:
        return 'Inactive';
    }
  }

  static ClientActivityStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'active':
        return ClientActivityStatus.active;
      case 'semiactive':
        return ClientActivityStatus.semiActive;
      case 'inactive':
        return ClientActivityStatus.inactive;
      default:
        return ClientActivityStatus.active;
    }
  }

  String toJson() => toString().split('.').last;
}