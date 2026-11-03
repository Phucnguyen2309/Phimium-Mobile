package com.be.config;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;

@Component
@Slf4j
public class SePayWebhookLoggingFilter extends OncePerRequestFilter {
    @Override protected boolean shouldNotFilter(HttpServletRequest r) {
        return !"/api/webhooks/sepay".equals(r.getServletPath());
    }
    @Override protected void doFilterInternal(HttpServletRequest request,HttpServletResponse response,FilterChain chain)
            throws ServletException,IOException {
        long start=System.nanoTime();
        try {chain.doFilter(request,response);}
        finally {log.info("SePay IPN httpStatus={} durationMs={}",response.getStatus(),(System.nanoTime()-start)/1_000_000);}
    }
}
