# Notatki z Nauki Godot 4

## Temat: Sygnały - signal.emit() vs emit_signal()
**Pytanie:** Jaka jest różnica pomiędzy signal.emit() a emit_signal("signal")?

**Odpowiedź:**
W Godot 4, **`signal.emit()`** jest absolutnym standardem i "Złotym Standardem", którego powinieneś używać. `emit_signal("nazwa")` to pozostałość po Godot 3 i rozwiązanie dla specyficznych przypadków.

Oto kluczowe różnice techniczne:

### 1. Bezpieczeństwo Typów i Refaktoryzacja (Najważniejsze)
*   **`signal.emit()`**: Jest traktowane jako "First-class citizen" w języku. Jeśli zmienisz nazwę sygnału w definicji (`signal my_signal`), edytor automatycznie zaktualizuje wszystkie wywołania `.emit()`. Jeśli podasz złą liczbę argumentów, edytor podkreśli to na czerwono **zanim** uruchomisz grę.
*   **`emit_signal("nazwa")`**: Opiera się na stringach (tzw. "stringly typed"). Jeśli zrobisz literówkę w nazwie sygnału (np. `"healh_changed"`) lub zmienisz nazwę sygnału w kodzie, `emit_signal` nie zostanie zaktualizowany i wyrzuci błąd dopiero w trakcie działania gry (Runtime Error).

### 2. Pythonowa Analogia
Jako programista Pythona, możesz o tym myśleć tak:
*   `my_signal.emit()` jest jak bezpośrednie wywołanie metody: `obj.my_method()`.
*   `emit_signal("my_signal")` jest jak użycie refleksji/introspection: `getattr(obj, "my_method")()`.

### 3. Wydajność
`signal.emit()` jest nieco szybsze, ponieważ pomija etap "lookupu" (wyszukiwania) sygnału w tablicy haszującej po nazwie stringa. W `emit()` referencja do Callable jest już znana.

### Przykład w kodzie (Godot 4)

```gdscript
extends Node

# Definicja sygnału
signal leveled_up(current_level: int)

func _ready() -> void:
	# --- SPOSÓB GODOT 4 (ZALECANY) ---
	# Edytor podpowiada argumenty i nazwę.
	# Kliknięcie F2 na 'leveled_up' zmieni nazwę również tutaj.
	leveled_up.emit(5)

	# --- SPOSÓB LEGACY / DYNAMICZNY ---
	# Podatne na literówki. Używaj TYLKO, jeśli nazwa sygnału
	# jest generowana dynamicznie w zmiennej typu String.
	emit_signal("leveled_up", 5)
```

**Podsumowując:** W swoim projekcie *Survivors* używaj wyłącznie składni `nazwa_sygnalu.emit()`.

## Temat: Animacje kodem - Tweens
**Pytanie:** Czym jest tween i jak go użyć? Sprawdź w dokumentacji!

**Odpowiedź:**
**Tween** (skrót od "in-between") to mechanizm służący do płynnej zmiany (interpolacji) wartości dowolnej właściwości obiektu w czasie. Pozwala tworzyć animacje bezpośrednio w kodzie, bez potrzeby używania węzła `AnimationPlayer`.

W Godot 4 "Złotym Standardem" jest użycie funkcji `create_tween()`, która tworzy lekki obiekt `SceneTreeTween`. Jest on automatycznie czyszczony po zakończeniu, więc nie musisz martwić się o pamięć.

### Kiedy używać?
*   Proste animacje UI (pojawianie się, znikanie, podskakiwanie).
*   Efekty "Fire and Forget" (np. flash po otrzymaniu obrażeń, unoszące się cyferki obrażeń).
*   Kiedy animacja zależy od dynamicznych wartości (np. przesuń się dokładnie do pozycji myszki).

### Jak używać? (Składnia Godot 4)
Najważniejsza metoda to `.tween_property(obiekt, "właściwość", wartość_końcowa, czas_trwania)`.

```gdscript
func animate_damage_flash() -> void:
	# 1. Tworzymy tween
	var tween = create_tween()

	# 2. Konfigurujemy (opcjonalnie) - np. ustawiamy, żeby animacje szły równolegle
	# domyślnie tweeny wykonują się sekwencyjnie (jeden po drugim)
	# tween.set_parallel()

	# 3. Definiujemy akcję: Zmień kolor modulacji na Czerwony w 0.2 sekundy
	tween.tween_property(self, "modulate", Color.RED, 0.2)		.set_ease(Tween.EASE_IN)		.set_trans(Tween.TRANS_CUBIC)

	# 4. Łańcuchowanie: Po zakończeniu powyższego, wróć do Białego
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)

	# 5. Callback: Po zakończeniu wszystkiego wywołaj funkcję (np. usuń obiekt)
	# tween.tween_callback(queue_free)
```

### Najważniejsze cechy:
1.  **Fluent Interface:** Możesz łączyć metody kropkami (`tween.tween_property(...).set_ease(...)`).
2.  **Automatyczne sprzątanie:** Tween usuwa się sam po zakończeniu (chyba że przypiszesz go do zmiennej i zatrzymasz ręcznie).
3.  **Sekwencyjność:** Domyślnie linie kodu `tween_property` wykonują się jedna po drugiej. Użyj `set_parallel()` jeśli chcesz, by działy się naraz.

**Pythonowa Analogia:**
To trochę jak asynchroniczna pętla `for`, która w tle zmienia wartość zmiennej od A do B, nie blokując reszty kodu (nie używa `time.sleep()`, tylko działa w klatkach silnika).

**Dokumentacja:** Klasa `SceneTreeTween` w Godot Docs.

## Temat: Skróty w dostępie do węzłów - $ i %
**Pytanie:** Czym różni się `$` od `%` w zapisie `@onready var count_label: Label = $%CountLabel`?

**Odpowiedź:**
Ten zapis łączy dwa mechanizmy Godota służące do nawigacji po drzewie sceny, poprawiając elastyczność i czytelność kodu.

### 1. `$` (get_node) - Ścieżka Względna
Znak dolara to skrót od funkcji `get_node()`. Pozwala na pobranie węzła na podstawie jego położenia w hierarchii.
*   `$Label` -> szuka dziecka o nazwie "Label".
*   `$UI/Container/Label` -> szuka węzła po konkretnej ścieżce.
**Wada:** Jeśli zmienisz strukturę sceny (np. przeniesiesz Label do innego kontenera), ścieżka przestanie działać i kod wyrzuci błąd.

### 2. `%` (Scene Unique Node) - Unikalna Nazwa
Znak procenta odwołuje się do węzła oznaczonego w edytorze jako **"Access as Unique Name"** (Prawy Przycisk Myszy na węźle -> zaznacz tę opcję). Obok węzła pojawi się wtedy mała ikona `%`.
*   Działa jak **ID w HTML**.
*   Wyszukuje węzeł w obrębie obecnej sceny bez względu na to, jak głęboko jest schowany.
*   **Zaleta:** Możecz dowolnie zmieniać strukturę sceny, a kod nadal będzie działał, dopóki węzeł znajduje się w tej samej scenie.

### 3. Zapis `$%`
Łączy oba symbole: `$%MyLabel` to skrót od `get_node("%MyLabel")`. Jest to "Złoty Standard" przy pracy z UI, gdzie hierarchia często się zmienia.

### Pythonowa Analogia
*   `$Path/To/Node` to jak szukanie w głęboko zagnieżdżonym słowniku: `data['UI']['Container']['Label']`.
*   `%UniqueNode` to jak szukanie po kluczu w płaskiej mapie ID: `global_registry['Label']`.

**Dobra Praktyka:** Używaj `%UniqueName` dla wszystkich elementów UI, do których odwołujesz się w skryptach. Dzięki temu Twój kod będzie odporny na refaktoryzację wizualną sceny.

## Temat: Kontenery danych - Inner Class vs Dictionary vs Resource
**Pytanie:** Czy lepiej używać Inner Class czy Dictionary do trzymania danych? I dlaczego Inner Class wywala błąd w sieci (MultiplayerSpawner)?

**Odpowiedź:**
Wybór zależy od przeznaczenia danych. **Inner Class** jest świetna do lokalnej logiki, ale **zawodzi w systemach sieciowych** Godota (RPC, MultiplayerSpawner).

### 1. Inner Class (Lokalny Kontener)
Zalety: Static typing, autocomplete, łatwy refaktoring.
**Kiedy używać:** Do wewnętrznej logiki skryptu (np. stan algorytmu, lokalne statystyki), które nie opuszczają danego obiektu.

### 2. Dictionary (Transport Sieciowy)
Zalety: Natywna serializacja. Godot wie, jak zamienić `Dictionary` na bajty i wysłać je przez sieć.
**Kiedy używać:** W systemach sieciowych (np. `multiplayer_spawner.spawn(data)`), przy parsowaniu JSON lub szybkich prototypach.

### 3. Resource (Złożone Dane & Inspektor)
Zalety: Serializacja + widoczność w Inspektorze + zapis do pliku `.tres`.
**Kiedy używać:** Gdy chcesz przesyłać złożone obiekty przez sieć (musi to być `class_name` w osobnym pliku) lub konfigurować dane w edytorze.

### Dlaczego Inner Class nie działa w sieci?
System sieciowy Godota operuje na typach **Variant**. `Inner Class` to niestandardowy obiekt (Object/RefCounted), którego silnik nie potrafi automatycznie zserializować "po kablu". Próba przesłania instancji Inner Class skończy się błędem `Failed to call spawn function` lub odebraniem `null`.

### Pythonowa Analogia
*   **Dictionary** jest jak surowy `dict`.
*   **Inner Class** jest jak lokalna klasa zdefiniowana wewnątrz funkcji/modułu.
*   **Resource** jest jak `dataclass` lub model `Pydantic`, który ma wbudowane metody `to_json()` / `from_json()`.

**Zasada kciuka:** Jeśli dane idą do `rpc()` lub `spawn()`, użyj `Dictionary` (dla prostych danych) lub `Resource` (dla złożonych). Unikaj `Inner Class` w komunikacji między-węzłowej.
