package com.harbormaster.security;

import java.util.Collection;
import java.util.stream.Collectors;


import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Component;

@Component
public class SpringSecurityCurrentIdentity
        implements CurrentIdentity {

    protected Authentication authentication() {

        return SecurityContextHolder
                .getContext()
                .getAuthentication();
    }

    @Override
    public boolean isAuthenticated() {

        Authentication authentication =
                authentication();

        return authentication != null &&
                authentication.isAuthenticated();
    }

    @Override
    public String getSubject() {

        Authentication authentication = authentication();

        if (authentication == null) {
            return null;
        }

        //
        // JWT Resource Server
        //
        if (authentication instanceof JwtAuthenticationToken jwt) {
            return jwt.getToken().getSubject();
        }

        //
        // OAuth2 Login
        //
        if (authentication instanceof OAuth2AuthenticationToken oauth) {
            return oauth.getName();
        }


        //
        // Form Login / LDAP
        //
        if (authentication instanceof UsernamePasswordAuthenticationToken usernamePassword) {

            Object principal = usernamePassword.getPrincipal();

          //  if (principal instanceof UserDetails user) {
            //    return user.getUsername();
            //}

            return usernamePassword.getName();
        }

        return authentication.getName();
    }

    @Override
    public String getUsername() {

        return getSubject();
    }

    @Override
    public String getOrganizationId() {

        Authentication authentication = authentication();

        if (authentication == null) {
            return null;
        }

        //
        // JWT Resource Server
        //
        if (authentication instanceof JwtAuthenticationToken jwt) {

            return jwt.getToken()
                    .getClaimAsString("organization");
        }

        //
        // OAuth2 Login
        //
        if (authentication instanceof OAuth2AuthenticationToken oauth) {

            // Provider-specific
            String organization =
                    oauth.getPrincipal()
                            .getAttribute("organization");

            if (organization != null) {
                return organization;
            }

            // Azure AD tenant
            return oauth.getPrincipal()
                    .getAttribute("tid");
        }

        //
        // Form Login / LDAP
        //
        if (authentication instanceof UsernamePasswordAuthenticationToken usernamePassword) {

            Object principal =
                    usernamePassword.getPrincipal();

          //  if (principal instanceof CurrentUser user) {

            //    return user.getOrganizationId();
            //}

            return null;
        }

        return null;
    }

    @Override
    public Collection<String> getAuthorities() {

        return authentication()
                .getAuthorities()
                .stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.toList());
    }

    @Override
    public boolean hasAuthority(
            String authority) {

        return authentication()
                .getAuthorities()
                .stream()
                .map(GrantedAuthority::getAuthority)
                .anyMatch(authority::equals);
    }

}