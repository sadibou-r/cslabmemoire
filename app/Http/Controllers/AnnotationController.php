<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Annotation;
use App\Models\Image;
use Illuminate\Support\Facades\DB;

class AnnotationController extends Controller
{
    // Créer une annotation
    // Créer plusieurs annotations en une seule requête
    public function storeBatch(Request $request){
        $request->validate([
            'annotations'   => 'required|array|min:1',
            'annotations.*.image_id' => 'required|exists:images,id',
            'annotations.*.grade'    => 'required|string',
            'annotations.*.stade'    => 'required|string',
        ]);

        $userId = $request->user()->id;

        DB::beginTransaction();
        try {
            $createdAnnotations = [];

            foreach ($request->annotations as $data) {
                $annotation = Annotation::create([
                    'image_id' => $data['image_id'],
                    'user_id'  => $userId,
                    'grade'    => $data['grade'],
                    'stade'    => $data['stade'],
                ]);

                $createdAnnotations[] = $annotation->id;
            }

            DB::commit();

            $annotationsWithRelations = Annotation::with(['user', 'image'])
                ->whereIn('id', $createdAnnotations)
                ->get();

            return response()->json([
                'message' => 'Batch annotations created successfully',
                'annotations' => $annotationsWithRelations
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Error while creating batch annotations',
                'error'   => $e->getMessage()
            ], 500);
        }
    }


    // Récupérer toutes les annotations (pas seulement celles du médecin connecté)
    public function allAnnotations()
    {
        return response()->json(
            Annotation::with(['user', 'image'])->get()
        );
    }

    public function getMyAnnotations(Request $request)
    {
        $userId = $request->user()->id;

        // Récupère toutes les annotations du médecin connecté avec l'image et l'utilisateur
        $annotations = Annotation::with(['image', 'user'])
            ->where('user_id', $userId)
            ->get();

        return response()->json($annotations);
    }
}
