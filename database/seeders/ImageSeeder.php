<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Image;
use Illuminate\Support\Facades\File;

class ImageSeeder extends Seeder
{
    public function run(): void
    {
        $files = File::files(storage_path('app/public/images'));

        foreach ($files as $file) {
            Image::updateOrCreate(
                ['path' => 'images/' . $file->getFilename()]
            );
        }
    }
}
