module.exports.handler = async () => {
  const responseMessage = 'Hello, World!';

  return {
    statusCode: 200,
    headers: {'Content-Type': 'application/json'},
    body: responseMessage,
  }
}