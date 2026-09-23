package com.harbormaster.exception;

public class DuplicateEntityException extends BusinessException {

    public DuplicateEntityException(String entity, String operation ) {
        super(  "DUPLICATE_ENTITY",
                entity,
                operation,
                "Duplicate entity " + entity + " found during operation " + operation
                );
    }
}