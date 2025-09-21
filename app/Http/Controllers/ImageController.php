<?php

namespace App\Http\Controllers;

use App\Models\Image;
use Illuminate\Http\Request;

class ImageController extends Controller
{
    // Récupérer un lot de 10 images non annotées
    public function getNextBatch(Request $request){
        $userId = $request->user()->id;

        // Taille d’un batch
        $batchSize = 25;

        // Total d’images
        $totalImages = Image::count();

        // Total de batchs
        $totalBatches = ceil($totalImages / $batchSize);

        // Nombre d’images déjà annotées par ce médecin
        $annotatedCount = \App\Models\Annotation::where('user_id', $userId)->count();

        // Batch courant (on ajoute 1 car si le médecin n’a encore rien annoté, il est au batch 1)
        $currentBatch = intval(floor($annotatedCount / $batchSize)) + 1;

        // Récupérer les images du prochain batch pour ce médecin
        $images = Image::whereDoesntHave('annotations', function($query) use ($userId) {
                            $query->where('user_id', $userId);
                        })
                        ->take($batchSize)
                        ->get();

        return response()->json([
            'current_batch' => $currentBatch,
            'total_batches' => $totalBatches,
            'images' => $images,
        ]);
    }
}
