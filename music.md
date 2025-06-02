# Music

This is a document showcasing my favorite music

## Albums

| Name                  | Artist            | Rating | Genre     |
|-----------------------|-------------------|--------|-----------|
| Test                  | Hello             | 3.5    | Funk      |
| Exercises in Futility | Mgla              | 5.0    | Metal     |
| Reflektor             | Arcade Fire       | 4.65   | Indie Pop |
| Vicious Delicious     | Infected Mushroom | 4.5    | Edm       |


### Best_Albums

These are the albums I enjoy the most

```sql
SELECT * FROM Albums WHERE Rating > 4.0 ORDER BY Rating Desc;
```
| _0                    | _1                | _2   | _3        |
|-----------------------|-------------------|------|-----------|
| Exercises in Futility | Mgla              | 5.0  | Metal     |
| Reflektor             | Arcade Fire       | 4.65 | Indie Pop |
| Vicious Delicious     | Infected Mushroom | 4.5  | Edm       |

### Metal_Albums

```sql
SELECT * FROM Albums WHERE Genre = 'Metal'
```
| _0                    | _1   | _2  | _3    |
|-----------------------|------|-----|-------|
| Exercises in Futility | Mgla | 5.0 | Metal |

## Produce

This is some of my favorite produce, I like a nice snack while listening to music.

| Produce_Name | Type  |
|--------------|-------|
| Apple        | Fruit |
| Potato       | Tuber |
| Orange       | Fruit |

```sql
SELECT Produce_Name FROM Produce WHERE Type = 'Fruit' ORDER BY Produce_Name DESC;
```
| _0     |
|--------|
| Orange |
| Apple  |

```sql
SELECT Produce_Name FROM Produce WHERE Type = 'Tuber' ORDER BY Produce_Name DESC;
```
| _0     |
|--------|
| Potato |
