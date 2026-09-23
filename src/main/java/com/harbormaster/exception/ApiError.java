package com.harbormaster.exception;

public class ApiError {

    private final int status;
    private final String errorCode;
    private final String message;

    public ApiError(
            int status,
            String errorCode,
            String message) {

        this.status = status;
        this.errorCode = errorCode;
        this.message = message;
    }

    public int getStatus() {
        return status;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public String getMessage() {
        return message;
    }
}