package com.harbormaster.metrics;

public interface ApplicationMetrics {

    void increment(
            String entity,
            String operation,
            String status);

    void recordDuration(
            String entity,
            String operation,
            long durationNanos);

    void recordException(
            String entity,
            String operation,
            String exception);
}