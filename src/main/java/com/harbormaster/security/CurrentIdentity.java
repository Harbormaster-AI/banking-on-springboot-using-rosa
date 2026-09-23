package com.harbormaster.security;

import java.util.Collection;

public interface CurrentIdentity {

    public boolean isAuthenticated();

    public String getSubject();

    public String getUsername();

    public String getOrganizationId();

    public Collection<String> getAuthorities();

    public boolean hasAuthority(String authority);


}