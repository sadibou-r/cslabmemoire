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

            // Optionnel: Ajouter quelques images de test ou simplement retourner
            $this->command->info('Le répertoire images a été créé mais est vide.');
            return;
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
                    ['path' => 'images/' . $file->getFilename()],
                    [
                        'name' => pathinfo($file->getFilename(), PATHINFO_FILENAME),
                        'size' => $file->getSize(),
                        'mime_type' => mime_content_type($file->getPathname()),
                    ]
                );

                $this->command->info('Image ajoutée: ' . $file->getFilename());
            }
        }
    }
}
