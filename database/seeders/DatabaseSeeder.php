<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // \App\Models\User::factory(10)->create();

        // \App\Models\User::factory()->create([
        //     'name' => 'Test User',
        //     'email' => 'test@example.com',
        // ]);

        \App\Models\User::create([
            'name' => 'Medecin Test 1',
            'email' => 'medecin_test_1',
            'password' => bcrypt('medecin_test_1_mdp'),
        ]);
        \App\Models\User::create([
            'name' => 'Medecin Test 2',
            'email' => 'medecin_test_2',
            'password' => bcrypt('medecin_test_2_mdp'),
        ]);
        \App\Models\User::create([
            'name' => 'Sadibou',
            'email' => 'csroot',
            'password' => bcrypt('csroot667'),
        ]);
        \App\Models\User::create([
            'name' => 'Medecin Test 3',
            'email' => 'medecin_test_3',
            'password' => bcrypt('medecin_test_3_mdp'),
        ]);
        $this->call(ImageSeeder::class);

    }
}
