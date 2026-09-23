package com.harbormaster.metrics;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

import org.springframework.stereotype.Component;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;

@Component
public class MicrometerApplicationMetrics
        implements ApplicationMetrics {

    private final MeterRegistry registry;

    private final Map<MetricKey, Counter> counters =
            new ConcurrentHashMap<>();

    private final Map<MetricKey, Timer> timers =
            new ConcurrentHashMap<>();

    public MicrometerApplicationMetrics(
            MeterRegistry registry) {

        this.registry = registry;
    }

    @Override
    public void increment(
            String entity,
            String operation,
            String status) {

        MetricKey key = new MetricKey();
        key.setEntity(entity);
        key.setOperation(operation);
        key.setStatus(status);

        Counter counter =
                counters.computeIfAbsent(
                        key,
                        this::createCounter);

        counter.increment();
    }

    @Override
    public void recordDuration(
            String entity,
            String operation,
            long durationNanos) {

        MetricKey key = new MetricKey();

        key.setEntity(entity);
        key.setOperation(operation);

        Timer timer =
                timers.computeIfAbsent(
                        key,
                        this::createTimer);

        timer.record(
                durationNanos,
                TimeUnit.NANOSECONDS);
    }

    @Override
    public void recordException(
            String entity,
            String operation,
            String exception) {

        increment(
                entity,
                operation,
                "failure");

        Counter.builder(MetricNames.EXCEPTIONS)
                .tag("entity", entity)
                .tag("operation", operation)
                .tag("exception", exception)
                .register(registry)
                .increment();
    }

    private Counter createCounter(
            MetricKey key) {

        return Counter.builder(MetricNames.OPERATIONS)
                .tag("entity", key.getEntity())
                .tag("operation", key.getOperation())
                .tag("status", key.getStatus())
                .register(registry);
    }

    private Timer createTimer(
            MetricKey key) {

        return Timer.builder(
                        MetricNames.OPERATION_DURATION)
                .tag("entity", key.getEntity())
                .tag("operation", key.getOperation())
                .register(registry);
    }
}