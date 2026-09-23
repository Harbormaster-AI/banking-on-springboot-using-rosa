package com.harbormaster.exception;

public class ValidationException extends BusinessException {

    public ValidationException(String entity, String operation ) {
        super(  "VALIDATION_ERROR",
                entity,
                operation,
                "Failed during validation of " + entity + " signaled during operation " + operation
                );
    }
}