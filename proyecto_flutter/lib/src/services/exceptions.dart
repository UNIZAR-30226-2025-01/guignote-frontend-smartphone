class ApiException implements Exception 
{
  final String message;

  ApiException(this.message);

}


class InvalidCredentialsException extends ApiException 
{
  InvalidCredentialsException(super.message);
}

class UserNotFoundException extends ApiException 
{
  UserNotFoundException(super.message);
}

class MethodNotAllowedException extends ApiException 
{
  MethodNotAllowedException(super.message);
}