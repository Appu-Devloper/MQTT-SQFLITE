class Connection {
  final String clientId;
  final String host;
  final String port;
  final String user;
  final String password;
  final String certificatePath;

  Connection({
    required this.clientId,
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.certificatePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'host': host,
      'port': port,
      'user': user,
      'password': password,
      'certificatePath': certificatePath,
    };
  }
}
