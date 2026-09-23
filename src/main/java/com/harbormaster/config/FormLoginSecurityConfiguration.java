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
    havingValue = "form-login")
public class FormLoginSecurityConfiguration {

    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http)
            throws Exception {
                        http
                            .csrf(csrf -> csrf.disable())
                            .authorizeHttpRequests(auth -> auth
                            .requestMatchers("/login").permitAll()
                            .anyRequest().authenticated())
                            .formLogin(Customizer.withDefaults());
        return http.build();
    }
}