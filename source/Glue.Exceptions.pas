unit Glue.Exceptions;

interface
uses System.SysUtils;

type

   EConverterNotFoundException = class(Exception);

   EIncompatibleDataConversionException = class(Exception);

   ECommandHandlerNotFoundException = class(Exception);

   ECommandTriggerNotFoundException = class(Exception);


implementation

end.