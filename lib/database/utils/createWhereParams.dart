String createWhereParams(Map<String, dynamic> params) {
  String queryParams = '';

  params.forEach((key, param) {
    queryParams += " OR ${key} = '${param}'";
  });

  return queryParams.substring(4);
}
