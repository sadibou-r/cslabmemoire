<?php

use App\Http\Controllers\AnnotationController;
use App\Http\Controllers\ImageController;
use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');

Route::middleware('auth:sanctum')->group(function () {

    // Infos utilisateur connecté
    Route::get('/user', function (\Illuminate\Http\Request $request) {
        return $request->user();
    });

    // Images
    Route::get('/images/next-batch', [ImageController::class, 'getNextBatch']);

    // Annotations
    Route::post('/batch-annotations', [AnnotationController::class, 'storeBatch']);
    Route::get('/annotations', [AnnotationController::class, 'allAnnotations']);
    Route::get('/annotations/annotated-by-me', [AnnotationController::class, 'getMyAnnotations']);

});
