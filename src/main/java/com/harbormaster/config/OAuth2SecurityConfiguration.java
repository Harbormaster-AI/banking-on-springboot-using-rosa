package com.harbormaster.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@ConditionalOnProperty(
    name = "hm.security.authentication",
    havingValue = "oauth2")
public class OAuth2SecurityConfiguration {

    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http)
            throws Exception {
                        http
                            .authorizeHttpRequests(auth -> auth
                            .requestMatchers("/", "/error").permitAll()
                            .anyRequest().authenticated())
                            .oauth2Login(Customizer.withDefaults());
        return http.build();
    }
}