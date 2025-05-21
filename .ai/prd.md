# Dokument wymagań produktu (PRD) - ReStyler Wnętrz AI
## 1. Przegląd produktu
Aplikacja webowa "ReStyler Wnętrz AI" ma na celu umożliwienie użytkownikom szybkiego i łatwego generowania inspirujących wizualizacji ich własnych wnętrz (takich jak sypialnie, kuchnie, salony) w odmiennych stylach, kolorystykach lub aranżacjach. Użytkownik przesyła zdjęcie swojego pomieszczenia, które służy jako referencja i inspiracja. Następnie, na podstawie tekstowego opisu (promptu) dostarczonego przez użytkownika, aplikacja wykorzystuje model DALL-E 3 do wygenerowania nowej wizji tego wnętrza. Głównym celem jest dostarczenie narzędzia do eksperymentowania z koncepcjami projektowymi bez ponoszenia fizycznych kosztów i wysiłku związanego z rzeczywistymi zmianami.

## 2. Problem użytkownika
Użytkownicy często napotykają trudności w zwizualizowaniu, jak ich obecne wnętrza mogłyby wyglądać po wprowadzeniu zmian stylistycznych, kolorystycznych lub aranżacyjnych. Planowanie remontu lub odświeżenia pomieszczenia wiąże się z niepewnością co do ostatecznego efektu, a tradycyjne metody (np. moodboardy, przeglądanie inspiracji online) nie zawsze pozwalają na zobaczenie konkretnej wizji zastosowanej do własnego wnętrza. To prowadzi do ryzyka podjęcia kosztownych decyzji, które mogą nie przynieść oczekiwanych rezultatów. Użytkownicy potrzebują prostego narzędzia, które pozwoli im "przymierzyć" różne koncepcje do ich przestrzeni przed podjęciem ostatecznych decyzji.

## 3. Wymagania funkcjonalne
### 3.1. Uwierzytelnianie użytkownika
   3.1.1. Użytkownik może zarejestrować nowe konto podając adres e-mail i hasło.
   3.1.2. Użytkownik może zalogować się na istniejące konto używając swojego adresu e-mail i hasła.
   3.1.3. System nie pozwala na rejestrację z już istniejącym adresem e-mail.
   3.1.4. Hasła są przechowywane w sposób bezpieczny (np. hashowane).

### 3.2. Generowanie wizualizacji wnętrz
   3.2.1. Użytkownik może przesłać zdjęcie swojego wnętrza.
      3.2.1.1. Akceptowane formaty plików graficznych to: PNG, JPG, WebP.
      3.2.1.2. W MVP nie ma zdefiniowanego limitu maksymalnego rozmiaru przesyłanego pliku.
   3.2.2. Użytkownik może wprowadzić tekstowy opis (prompt) oczekiwanych zmian (np. styl, kolory, kluczowe elementy).
   3.2.3. Aplikacja wysyła przesłane zdjęcie (jako referencję wizualną do precyzyjnego odwzorowania) oraz prompt do API DALL-E 3 w celu wygenerowania nowego obrazu.
   3.2.4. Aplikacja wyświetla pojedynczy wygenerowany obraz użytkownikowi.
   3.2.5. Proces generowania obrazu ma limit czasowy 10 sekund. Po przekroczeniu tego limitu, użytkownikowi wyświetlany jest komunikat błędu informujący o niepowodzeniu i zachęcający do ponownej próby.
   3.2.6. Interfejs do przesyłania zdjęcia i wprowadzania promptu jest zintegrowany w jednym formularzu/ekranie.

### 3.3. Historia generacji
   3.3.1. Zalogowany użytkownik ma dostęp do historii swoich poprzednich generacji.
   3.3.2. Każdy wpis w historii zawiera: przesłane zdjęcie referencyjne, użyty prompt oraz wygenerowany obraz.
   3.3.3. Użytkownik może usunąć pojedyncze wpisy ze swojej historii generacji.

### 3.4. Limity użytkowania
   3.4.1. Każdy zarejestrowany użytkownik ma limit 3 generacji obrazów dziennie.
   3.4.2. System informuje użytkownika o osiągnięciu dziennego limitu.

## 4. Granice produktu
Następujące funkcjonalności i aspekty NIE wchodzą w zakres MVP (Minimum Viable Product) i mogą zostać rozważone w przyszłych iteracjach:
*   Zaawansowane narzędzia edycji obrazu wejściowego (np. kadrowanie, korekcja kolorów).
*   Automatyczne sugestie promptów na podstawie analizy zdjęcia.
*   Predefiniowane szablony stylów lub palet kolorów do wyboru.
*   Funkcje społecznościowe (np. udostępnianie, komentowanie, polubienia generacji).
*   Wersjonowanie generacji lub możliwość iterowania na poprzednio wygenerowanym obrazie.
*   Generowanie obrazów w ultrawysokiej rozdzielczości.
*   Integracja z platformami e-commerce (np. linkowanie do mebli/dodatków).
*   System "projektów" do grupowania wielu generacji.
*   Natywne aplikacje mobilne (iOS/Android).
*   Zaawansowane zarządzanie kontem użytkownika (np. zmiana emaila).
*   System płatności, subskrypcji lub płatnych dodatkowych generacji.
*   Wykorzystanie zdjęcia jako bezpośredniego "image-to-image" w stylu ControlNet, jeśli wymaga to zaawansowanej implementacji poza standardowymi możliwościami edycji API DALL-E 3.
*   Dostarczanie użytkownikowi wskazówek lub przykładów efektywnych promptów.
*   Specjalne mechanizmy obsługi sytuacji, gdy wygenerowany obraz jest niskiej jakości, nieadekwatny do promptu, lub zawiera artefakty (poza ogólnym błędem timeout).
*   Dedykowane mechanizmy zbierania opinii od użytkowników w ramach aplikacji.
*   Logowanie za pomocą kont zewnętrznych (np. Google, Facebook).
*   Szczegółowe zarządzanie kosztami API DALL-E 3, plan awaryjny na wypadek zmian w API, kompleksowe uregulowania prawne (poza podstawowym regulaminem i polityką prywatności niezbędnymi do uruchomienia), czy rozważania etyczne dotyczące generowanych treści.

## 5. Historyjki użytkowników

### Uwierzytelnianie i Zarządzanie Kontem
ID: US-001
Tytuł: Rejestracja nowego użytkownika
Opis: Jako nowy użytkownik, chcę móc zarejestrować się w aplikacji używając mojego adresu email i hasła, aby uzyskać dostęp do jej funkcjonalności i zapisywać moje generacje.
Kryteria akceptacji:
    - Po wejściu na stronę rejestracji, widzę formularz z polami na adres email, hasło i potwierdzenie hasła.
    - Po wypełnieniu formularza poprawnymi danymi (unikalny email, hasło zgodne z wymaganiami, hasła pasujące) i kliknięciu "Zarejestruj", moje konto jest tworzone.
    - Jestem informowany o pomyślnej rejestracji i mogę się zalogować.
    - Jeśli podam email, który już istnieje w systemie, otrzymuję komunikat błędu informujący o tym.
    - Jeśli podam niepoprawny format emaila, otrzymuję stosowny komunikat błędu.
    - Jeśli hasła w polach "hasło" i "potwierdź hasło" nie są identyczne, otrzymuję komunikat błędu.
    - Jeśli hasło nie spełnia minimalnych kryteriów bezpieczeństwa (np. długość), otrzymuję komunikat błędu.

ID: US-002
Tytuł: Logowanie istniejącego użytkownika
Opis: Jako zarejestrowany użytkownik, chcę móc zalogować się do aplikacji używając mojego adresu email i hasła, aby uzyskać dostęp do moich poprzednich generacji i tworzyć nowe.
Kryteria akceptacji:
    - Po wejściu na stronę logowania, widzę formularz z polami na adres email i hasło.
    - Po podaniu prawidłowego emaila i hasła i kliknięciu "Zaloguj", jestem zalogowany do systemu.
    - Jeśli podam nieprawidłowy email lub hasło, otrzymuję komunikat błędu.
    - Po pomyślnym zalogowaniu, jestem przekierowany do głównego interfejsu aplikacji (np. panelu generowania).

ID: US-003
Tytuł: Wylogowanie użytkownika
Opis: Jako zalogowany użytkownik, chcę móc się wylogować z aplikacji, aby zakończyć sesję i zabezpieczyć moje konto.
Kryteria akceptacji:
    - W interfejsie aplikacji dostępny jest przycisk/link "Wyloguj".
    - Po kliknięciu "Wyloguj", moja sesja zostaje zakończona.
    - Jestem przekierowany na stronę główną lub stronę logowania.

### Generowanie Wizualizacji
ID: US-004
Tytuł: Przesyłanie zdjęcia i wprowadzanie promptu
Opis: Jako zalogowany użytkownik, chcę móc przesłać zdjęcie mojego wnętrza i wpisać tekstowy opis pożądanych zmian (prompt) w jednym formularzu, aby zainicjować proces generowania nowej wizualizacji.
Kryteria akceptacji:
    - Na stronie generowania widzę pole do przesłania pliku graficznego oraz pole tekstowe do wpisania promptu.
    - Mogę wybrać plik graficzny (PNG, JPG, WebP) z mojego urządzenia.
    - Po wybraniu pliku, widzę jego podgląd lub nazwę.
    - Mogę wpisać tekst w polu prompt.
    - Dostępny jest przycisk "Generuj" (lub podobny) do rozpoczęcia procesu.
    - Przycisk "Generuj" jest aktywny tylko, jeśli przesłano plik i wpisano jakikolwiek tekst w prompcie.

ID: US-005
Tytuł: Generowanie i wyświetlanie wizualizacji
Opis: Jako użytkownik, po przesłaniu zdjęcia i wpisaniu promptu, chcę, aby aplikacja wygenerowała i wyświetliła nową wizualizację mojego wnętrza.
Kryteria akceptacji:
    - Po kliknięciu "Generuj", widzę wskaźnik ładowania informujący o trwającym procesie.
    - Wizualizacja jest generowana przez DALL-E 3 na podstawie mojego zdjęcia i promptu.
    - Wygenerowany obraz (pojedynczy) jest wyświetlany na ekranie w ciągu maksymalnie 10 sekund.
    - Wygenerowany obraz jest czytelny i ma akceptowalną jakość.
    - Jeśli generowanie trwa dłużej niż 10 sekund, proces jest przerywany, a ja widzę komunikat błędu: "Spróbuj jeszcze raz, coś poszło nie tak".

ID: US-006
Tytuł: Ograniczenie liczby generacji
Opis: Jako użytkownik, jestem świadomy, że mogę wykonać ograniczoną liczbę generacji dziennie.
Kryteria akceptacji:
    - System śledzi liczbę generacji wykonanych przez zalogowanego użytkownika w ciągu dnia.
    - Mogę wykonać maksymalnie 3 generacje dziennie.
    - Po wykonaniu trzeciej generacji, przy próbie kolejnej generacji tego samego dnia, widzę komunikat informujący o osiągnięciu dziennego limitu i o tym, kiedy będę mógł ponownie generować obrazy.
    - Przycisk "Generuj" staje się nieaktywny po osiągnięciu limitu.

### Historia Generacji
ID: US-007
Tytuł: Dostęp do historii generacji
Opis: Jako zalogowany użytkownik, chcę mieć dostęp do listy moich poprzednich generacji, abym mógł je przejrzeć.
Kryteria akceptacji:
    - W aplikacji dostępna jest sekcja "Moje Generacje" (lub podobna).
    - W tej sekcji widzę listę moich poprzednich generacji, posortowaną od najnowszej do najstarszej.
    - Każdy element listy zawiera miniaturkę przesłanego zdjęcia referencyjnego, użyty prompt (lub jego fragment) i miniaturkę wygenerowanego obrazu.
    - Kliknięcie na element listy pozwala zobaczyć większy podgląd wygenerowanego obrazu, pełny prompt i zdjęcie referencyjne.

ID: US-008
Tytuł: Usuwanie generacji z historii
Opis: Jako zalogowany użytkownik, chcę móc usunąć wybrane pozycje z mojej historii generacji, aby zarządzać moimi danymi.
Kryteria akceptacji:
    - Przy każdym wpisie w historii generacji (lub na stronie szczegółów generacji) dostępna jest opcja "Usuń".
    - Po kliknięciu "Usuń", pojawia się prośba o potwierdzenie operacji.
    - Po potwierdzeniu, wybrana generacja jest trwale usuwana z mojej historii.
    - Usunięcie generacji nie wpływa na mój dzienny limit generacji.

## 6. Metryki sukcesu
Kluczowe wskaźniki (KPIs) do mierzenia sukcesu MVP:

### 6.1. Funkcjonalność Rdzenia
   6.1.1. Współczynnik pomyślnych generacji: (Liczba pomyślnie zakończonych generacji) / (Całkowita liczba prób generacji). Cel: > 95%.
   6.1.2. Liczba krytycznych błędów: Monitorowanie logów pod kątem błędów uniemożliwiających kluczowe przepływy użytkownika (rejestracja, logowanie, generowanie). Cel: < 1% sesji z krytycznym błędem.

### 6.2. Użyteczność i Prostota
   6.2.1. Wykorzystanie dziennego limitu generacji: Odsetek aktywnych użytkowników, którzy wykorzystują swój pełny dzienny limit (3 generacje). Cel: > 20% aktywnych użytkowników dziennie.
   6.2.2. Czas spędzony na zadaniu generowania: Średni czas od przesłania zdjęcia do otrzymania wyniku (nie licząc czasu oczekiwania na API, a czas interakcji użytkownika). Cel: Utrzymanie prostoty interfejsu.

### 6.3. Wartość dla Użytkownika (pośrednio przez retencję)
   6.3.1. Retencja tygodniowa (Week 1 Retention): Odsetek nowo zarejestrowanych użytkowników, którzy powracają do aplikacji co najmniej raz w ciągu pierwszego tygodnia od rejestracji. Cel: > 15%.
   6.3.2. Retencja aktywnych użytkowników: Odsetek użytkowników, którzy byli aktywni w poprzednim tygodniu i są aktywni również w bieżącym tygodniu.

### 6.4. Stabilność
   6.4.1. Czas dostępności usługi (Uptime): Procent czasu, w którym aplikacja jest dostępna i działa poprawnie. Cel: > 99.5%.
   6.4.2. Odsetek błędów timeout: (Liczba błędów timeout przy generacji) / (Całkowita liczba prób generacji). Cel: < 5%.