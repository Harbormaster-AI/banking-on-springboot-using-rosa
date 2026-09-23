package com.harbormaster.exception;

public class ExternalServiceException extends BusinessException {

    public ExternalServiceException(String entity, String  operation ) {
        super(  "EXTERNAL_SERVICE",
                entity,
                operation,
                "An exception on an extenal service using " + entity + " signaled during operation " + operation
                );
    }
}