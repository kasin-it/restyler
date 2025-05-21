# Schemat Bazy Danych PostgreSQL dla ReStyler Wnętrz AI

## 1. Typy Wyliczeniowe (ENUMs)

### `generation_status_enum`
Definiuje możliwe statusy procesu generowania obrazu.

```sql
CREATE TYPE public.generation_status_enum AS ENUM (
    'oczekująca',
    'przetwarzanie',
    'zakończono_pomyślnie',
    'błąd_api_dalle',
    'błąd_timeout',
    'błąd_wewnętrzny'
);
```

## 2. Lista Tabel z Kolumnami, Typami Danych i Ograniczeniami

### Tabela: `public.profiles`
Przechowuje dodatkowe informacje o profilach użytkowników, rozszerzając tabelę `auth.users` dostarczaną przez Supabase.

| Nazwa Kolumny | Typ Danych  | Ograniczenia                                                              | Opis                                                                |
|---------------|-------------|---------------------------------------------------------------------------|---------------------------------------------------------------------|
| `user_id`     | `UUID`      | `PRIMARY KEY`, `REFERENCES auth.users(id) ON DELETE CASCADE`              | Klucz główny, klucz obcy do `auth.users.id`.                         |
| `created_at`  | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()`                                                  | Znacznik czasu utworzenia profilu (przechowywany w UTC).             |
| `updated_at`  | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()`                                                  | Znacznik czasu ostatniej aktualizacji profilu (przechowywany w UTC). |
| `daily_generation_count` | `SMALLINT` | `NOT NULL DEFAULT 0`                                         | Licznik generacji wykonanych przez użytkownika danego dnia.        |
| `last_generation_date` | `DATE` | `NULL`                                                              | Data ostatniej generacji (używana do resetowania licznika).          |

*Uwaga: Rozważenie dodania triggera do automatycznej aktualizacji `updated_at`.*

### Tabela: `public.generations`
Przechowuje informacje o każdej próbie wygenerowania wizualizacji wnętrza.

| Nazwa Kolumny             | Typ Danych                 | Ograniczenia                                                              | Opis                                                                    |
|---------------------------|----------------------------|---------------------------------------------------------------------------|-------------------------------------------------------------------------|
| `id`                      | `SERIAL`                   | `PRIMARY KEY`                                                             | Unikalny identyfikator generacji (autoinkrementujący).                   |
| `user_id`                 | `UUID`                     | `NOT NULL`, `REFERENCES auth.users(id) ON DELETE CASCADE`                 | Identyfikator użytkownika, który zlecił generację.                        |
| `reference_image_location`| `TEXT`                     | `NOT NULL`                                                                | Ścieżka/klucz do obrazu referencyjnego w Supabase Storage.                |
| `prompt_text`             | `VARCHAR(1000)`            | `NOT NULL`                                                                | Tekstowy opis (prompt) użyty do generowania.                             |
| `generated_image_location`| `TEXT`                     |                                                                           | Ścieżka/klucz do wygenerowanego obrazu w Supabase Storage (NULL jeśli błąd).|
| `generation_status`       | `public.generation_status_enum` | `NOT NULL DEFAULT 'oczekująca'`                                      | Status procesu generowania obrazu.                                      |
| `status_message`          | `TEXT`                     |                                                                           | Opcjonalny komunikat błędu lub dodatkowe informacje o statusie.        |
| `created_at`              | `TIMESTAMPTZ`              | `NOT NULL DEFAULT NOW()`                                                  | Znacznik czasu utworzenia rekordu generacji (przechowywany w UTC).       |

## 3. Relacje Między Tabelami

1.  **`auth.users` (1) --- (1) `public.profiles`**
    *   Typ: Jeden-do-jednego (1:1)
    *   Klucz obcy: `public.profiles.user_id` odwołuje się do `auth.users.id`.
    *   Zachowanie przy usuwaniu: `ON DELETE CASCADE` (usunięcie użytkownika z `auth.users` spowoduje usunięcie powiązanego profilu).

2.  **`auth.users` (1) --- (N) `public.generations`**
    *   Typ: Jeden-do-wielu (1:N)
    *   Klucz obcy: `public.generations.user_id` odwołuje się do `auth.users.id`.
    *   Zachowanie przy usuwaniu: `ON DELETE CASCADE` (usunięcie użytkownika z `auth.users` spowoduje usunięcie wszystkich jego generacji).

## 4. Indeksy

### Tabela `public.profiles`:
*   `profiles_pkey` ON `user_id` (automatycznie utworzony dla klucza głównego).

### Tabela `public.generations`:
*   `generations_pkey` ON `id` (automatycznie utworzony dla klucza głównego).
*   `idx_generations_user_id_created_at` ON `user_id, created_at DESC` (do szybkiego wyszukiwania generacji użytkownika posortowanych od najnowszej, np. dla historii generacji i sprawdzania limitu).

## 5. Zasady PostgreSQL (Row Level Security - RLS)

Należy włączyć RLS dla poniższych tabel:
```sql
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.generations ENABLE ROW LEVEL SECURITY;
```

### Polityki dla tabeli `public.profiles`:
1.  **Użytkownicy mogą odczytywać własny profil:**
    ```sql
    CREATE POLICY "Allow individual user read access to their own profile"
    ON public.profiles
    FOR SELECT
    USING (auth.uid() = user_id);
    ```
2.  **Użytkownicy mogą aktualizować własny profil:**
    ```sql
    CREATE POLICY "Allow individual user update access to their own profile"
    ON public.profiles
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
    ```
 *Uwaga: MVP nie przewiduje tworzenia profili bezpośrednio przez użytkownika (tworzone np. triggerem po rejestracji w `auth.users`) ani ich usuwania (cascade z `auth.users`). Jeśli byłyby potrzebne, odpowiednie polityki INSERT/DELETE musiałyby zostać dodane.*

### Polityki dla tabeli `public.generations`:
1.  **Użytkownicy mogą odczytywać własne generacje:**
    ```sql
    CREATE POLICY "Allow individual user read access to their own generations"
    ON public.generations
    FOR SELECT
    USING (auth.uid() = user_id);
    ```
2.  **Użytkownicy mogą tworzyć generacje dla siebie:**
    ```sql
    CREATE POLICY "Allow individual user to insert their own generations"
    ON public.generations
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);
    ```
3.  **Użytkownicy mogą usuwać własne generacje:**
    ```sql
    CREATE POLICY "Allow individual user to delete their own generations"
    ON public.generations
    FOR DELETE
    USING (auth.uid() = user_id);
    ```
*Uwaga: Aktualizacja rekordów generacji przez użytkowników nie jest dozwolona w MVP. Dlatego nie ma polityki `UPDATE` dla użytkowników.*

## 6. Dodatkowe Uwagi i Wyjaśnienia

1.  **Usuwanie Plików z Supabase Storage:**
    *   Kluczowe jest zaimplementowanie mechanizmu (np. funkcji PostgreSQL wywoływanych przez triggery `AFTER DELETE` na tabeli `public.generations`) do automatycznego usuwania odpowiednich plików (`reference_image_location`, `generated_image_location`) z Supabase Storage, gdy rekord generacji jest usuwany. Dotyczy to zarówno bezpośredniego usuwania przez użytkownika, jak i kaskadowego usuwania po usunięciu użytkownika. Ta logika znajduje się poza definicjami tabel, ale jest krytyczna dla spójności danych.
    *   Przykład sygnatury funkcji (implementacja wymaga dostępu do API Supabase Storage, co zwykle robi się przez `pg_net` lub dedykowane rozszerzenia/funkcje Supabase):
        ```sql
        -- Pseudokod funkcji, rzeczywista implementacja zależy od narzędzi Supabase
        CREATE OR REPLACE FUNCTION handle_deleted_generation()
        RETURNS TRIGGER AS $$
        BEGIN
            -- Logika usuwania OLD.reference_image_location z Supabase Storage
            -- Logika usuwania OLD.generated_image_location z Supabase Storage
            -- Należy obsłużyć przypadki, gdy ścieżki są NULL lub puste
            -- SELECT extensions.storage_remove_object('bucket_name', OLD.reference_image_location);
            -- SELECT extensions.storage_remove_object('bucket_name', OLD.generated_image_location);
            RETURN OLD;
        END;
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER on_generation_deleted
        AFTER DELETE ON public.generations
        FOR EACH ROW EXECUTE FUNCTION handle_deleted_generation();
        ```

2.  **Implementacja Dziennego Limitu Generacji (PRD 3.4.1):**
    *   Logika dziennego limitu (3 generacje na użytkownika dziennie) będzie realizowana głównie w warstwie aplikacji przed zapisem do tabeli `generations`. Aplikacja powinna:
        1.  Sprawdzić `profiles.last_generation_date` i `profiles.daily_generation_count`.
        2.  Jeśli `last_generation_date` jest wcześniejsza niż bieżąca data (UTC), zresetować `daily_generation_count` do 0 i zaktualizować `last_generation_date`.
        3.  Jeśli `daily_generation_count` < 3, pozwolić na generację i inkrementować licznik.
        4.  Jeśli `daily_generation_count` >= 3, odrzucić żądanie.
    *   Alternatywnie, można rozważyć użycie funkcji PostgreSQL wywoływanej przez trigger `BEFORE INSERT` na `generations` do walidacji i aktualizacji licznika, co zapewniłoby integralność na poziomie bazy danych, ale może być bardziej skomplikowane w zarządzaniu czasem UTC i datami. Pola `daily_generation_count` i `last_generation_date` w tabeli `profiles` zostały dodane, aby wspierać tę logikę.

3.  **Tworzenie Profilu Użytkownika:**
    *   Zaleca się utworzenie funkcji PostgreSQL i triggera na tabeli `auth.users` (jeśli Supabase na to pozwala i jest to zgodne z ich modelem zarządzania użytkownikami) lub obsługę w logice aplikacyjnej, aby automatycznie tworzyć wpis w `public.profiles` po pomyślnej rejestracji nowego użytkownika.
        ```sql
        -- Funkcja do tworzenia profilu
        CREATE OR REPLACE FUNCTION public.handle_new_user()
        RETURNS TRIGGER AS $$
        BEGIN
            INSERT INTO public.profiles (user_id, updated_at)
            VALUES (NEW.id, NOW());
            RETURN NEW;
        END;
        $$ LANGUAGE plpgsql SECURITY DEFINER; -- Użyj SECURITY DEFINER ostrożnie

        -- Trigger na tabeli auth.users
        CREATE TRIGGER on_auth_user_created
        AFTER INSERT ON auth.users
        FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
        ```
    *   Jeśli trigger na `auth.users` nie jest możliwy/zalecany, proces ten musi być obsłużony po stronie backendu aplikacji.

4.  **Transakcyjność:**
    *   Operacje obejmujące zarówno modyfikacje w bazie danych (np. wstawienie rekordu do `generations`) jak i interakcje z zewnętrznymi serwisami (np. przesyłanie plików do Supabase Storage, wywołanie API DALL-E) powinny być zarządzane w sposób zapewniający spójność. Np. jeśli zapis pliku do Storage się nie powiedzie, rekord w `generations` nie powinien zostać utrwalony lub powinien być odpowiednio oznaczony.

5.  **Typ `TEXT` vs `VARCHAR(n)`:**
    *   Dla `reference_image_location` i `generated_image_location` użyto `TEXT`, ponieważ długość URL/ścieżki może być zmienna i potencjalnie długa. PostgreSQL efektywnie zarządza typem `TEXT`.
    *   Dla `prompt_text` użyto `VARCHAR(1000)` zgodnie z wymaganiami.

6.  **Strefy Czasowe:**
    *   Wszystkie kolumny `TIMESTAMPTZ` przechowują datę i czas w UTC, zgodnie z najlepszymi praktykami i ustaleniami.

7.  **Normalizacja:**
    *   Schemat jest znormalizowany (prawdopodobnie do 3NF), co jest odpowiednie dla tego typu aplikacji. Denormalizacja nie wydaje się konieczna na tym etapie.