package com.splitledger.common;

public record ErrorResponse(int status, String error, String message) {
}