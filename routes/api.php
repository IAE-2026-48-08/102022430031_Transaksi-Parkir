<?php

use App\Http\Controllers\TransactionController;
use Illuminate\Support\Facades\Route;

Route::middleware('apikey')->group(function () {
    Route::prefix('v1')->group(function () {
        Route::get('/transactions', [TransactionController::class, 'index']);
        Route::get('/transactions/{id}', [TransactionController::class, 'show']);
        Route::post('/transactions', [TransactionController::class, 'store']);
        Route::put('/transactions/{id}', [TransactionController::class, 'update']);
    });
});