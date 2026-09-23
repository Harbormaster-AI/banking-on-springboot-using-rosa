package com.harbormaster.exception;

public abstract class BusinessException
        extends RuntimeException {

    private final String errorCode;
    private final String entity;
    private final String operation;

    protected BusinessException(
            String errorCode,
            String entity,
            String operation,
            String message) {

        super(message);

        this.errorCode = errorCode;
        this.entity = entity;
        this.operation = operation;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public String getEntity() {
        return entity;
    }

    public String getOperation() {
        return operation;
    }

    // getters...
}