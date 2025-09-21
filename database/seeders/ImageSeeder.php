<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Image;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;

class ImageSeeder extends Seeder
{
    public function run(): void
    {
        $imagesPath = storage_path('app/public/images');

        // Créer le répertoire s'il n'existe pas
        if (!File::exists($imagesPath)) {
            File::makeDirectory($imagesPath, 0755, true);
            $this->createTestImages($imagesPath);
        }

        $files = File::files($imagesPath);

        if (empty($files)) {
            $this->command->info('Aucune image trouvée dans le répertoire.');
            return;
        }

        foreach ($files as $file) {
            // Vérifier que c'est bien un fichier image
            $extension = strtolower($file->getExtension());
            if (in_array($extension, ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'])) {
                Image::updateOrCreate(
                    ['path' => 'images/' . $file->getFilename()]
                );

                $this->command->info('Image ajoutée: ' . $file->getFilename());
            }
        }
    }

    private function createTestImages($path)
    {
        // Créer des images SVG de test
        $testImages = [
            [
                'filename' => 'test-image-1.svg',
                'content' => '<svg width="300" height="200" xmlns="http://www.w3.org/2000/svg">
                    <rect width="100%" height="100%" fill="#e3f2fd"/>
                    <text x="50%" y="50%" font-family="Arial" font-size="20" fill="#1976d2" text-anchor="middle" dy=".3em">Image Test 1</text>
                </svg>'
            ],
            [
                'filename' => 'test-image-2.svg',
                'content' => '<svg width="300" height="200" xmlns="http://www.w3.org/2000/svg">
                    <rect width="100%" height="100%" fill="#f3e5f5"/>
                    <text x="50%" y="50%" font-family="Arial" font-size="20" fill="#7b1fa2" text-anchor="middle" dy=".3em">Image Test 2</text>
                </svg>'
            ],
            [
                'filename' => 'test-image-3.svg',
                'content' => '<svg width="300" height="200" xmlns="http://www.w3.org/2000/svg">
                    <rect width="100%" height="100%" fill="#e8f5e8"/>
                    <text x="50%" y="50%" font-family="Arial" font-size="20" fill="#388e3c" text-anchor="middle" dy=".3em">Image Test 3</text>
                </svg>'
            ]
        ];

        foreach ($testImages as $image) {
            $filePath = $path . '/' . $image['filename'];
            File::put($filePath, $image['content']);
            $this->command->info('Image de test créée: ' . $image['filename']);
        }
}
}
