package com.splitledger.auth;

public record AuthResponse(String token, Long userId, String name, String email) {
}