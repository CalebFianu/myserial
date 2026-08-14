package com.myserial.api.controller;

import com.myserial.api.exception.UnauthorizedException;
import com.myserial.domain.entity.User;
import org.springframework.security.core.context.SecurityContextHolder;

public abstract class BaseController {

    protected Long currentUserId() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof User user) {
            return user.getId();
        }
        throw new UnauthorizedException("Not authenticated");
    }

    protected User currentUser() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof User user) {
            return user;
        }
        throw new UnauthorizedException("Not authenticated");
    }
}
