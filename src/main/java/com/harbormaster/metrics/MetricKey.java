package com.harbormaster.metrics;

public class MetricKey {

    public MetricKey() {}

    public MetricKey(String entity, String operation, String status) {
        this.entity = entity;
        this.operation = operation;
        this.status = status;
    }

    public String getMetric() {
        return metric;
    }

    public void setMetric(String metric) {
        this.metric = metric;
    }

    public String getEntity() {
        return entity;
    }

    public void setEntity(String entity) {
        this.entity = entity;
    }

    public String getOperation() {
        return operation;
    }

    public void setOperation(String operation) {
        this.operation = operation;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    protected String metric;
    protected String entity;
    protected String operation;
    protected String status;

}