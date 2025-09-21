<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Image extends Model
{
    use HasFactory;

    protected $fillable = ['path']; // mets ici les colonnes de ta table "images"

    public function annotations()
    {
        return $this->hasMany(Annotation::class);
    }
}
