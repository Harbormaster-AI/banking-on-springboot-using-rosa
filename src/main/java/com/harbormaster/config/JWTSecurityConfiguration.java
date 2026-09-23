package com.harbormaster.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration()
@ConditionalOnProperty(
        name = "hm.security.authentication",
        havingValue = "jwt")
public class JWTSecurityConfiguration {

    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http)
            throws Exception {
                        http
                            .csrf(csrf -> csrf.disable())
                            .authorizeHttpRequests(auth -> auth
                            .requestMatchers("/actuator/health").permitAll()
                            .anyRequest().authenticated())
                            .oauth2ResourceServer(oauth ->
                                oauth.jwt(Customizer.withDefaults()));

        return http.build();
    }
}