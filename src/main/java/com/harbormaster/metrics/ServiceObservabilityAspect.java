package com.harbormaster.metrics;

import com.harbormaster.security.CurrentIdentity;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.MDC;
import org.springframework.stereotype.Component;

@Aspect
@Component
public class ServiceObservabilityAspect {

    private final ApplicationMetrics metrics;
    private final CurrentIdentity currentIdentity;

    public ServiceObservabilityAspect(
            ApplicationMetrics metrics,
            CurrentIdentity currentIdentity) {

        this.metrics = metrics;
        this.currentIdentity = currentIdentity;
    }

    @Around("execution(public * com.harbormaster..service..*(..))")
    public Object observe(ProceedingJoinPoint pjp)
            throws Throwable {

        long start = System.nanoTime();

        Class<?> serviceClass =
                pjp.getTarget().getClass();

        String serviceName =
                serviceClass.getSimpleName();

        // CustomerService -> Customer
        String entity =
                serviceName.replace("Service", "");

        // create(), update(), delete(), approve(), ...
        String operation =
                pjp.getSignature().getName();

        try {
            //
            // Populate the logging context
            //
            MDC.put("entity", entity);
            MDC.put("operation", operation);

            if (currentIdentity != null) {

                if (currentIdentity.getSubject() != null) {
                    MDC.put("userId",
                            currentIdentity.getSubject());
                }

                if (currentIdentity.getOrganizationId() != null) {
                    MDC.put("organizationId",
                            currentIdentity.getOrganizationId());
                }
            }

            //
            // Execute the service
            //
            Object result = pjp.proceed();

            //
            // Metrics
            //
            metrics.increment(
                    entity,
                    operation,
                    "success");

            metrics.recordDuration(
                    entity,
                    operation,
                    System.nanoTime() - start);

            return result;

        } catch (Exception ex) {

            metrics.increment(
                    entity,
                    operation,
                    "failure");

            metrics.recordException(
                    entity,
                    operation,
                    ex.getClass().getSimpleName());

            throw ex;

        } finally {

            //
            // Remove only what we added.
            //
            MDC.remove("entity");
            MDC.remove("operation");
            MDC.remove("userId");
            MDC.remove("organizationId");
        }
    }
}