## Albums

| Name                  | Artist            | Rating |
|-----------------------|-------------------|--------|
| Test                  | Hello             | 3.5    |
| Exercises in Futility | Mgla              | 5.0    |
| Reflektor             | Arcade Fire       | 4.65   |
| Vicious Delicious     | Infected Mushroom | 4.5    |

### Best_Albums

```sql
SELECT * FROM Albums 
WHERE Rating > 4.0
ORDER BY Rating Desc;
```
| _0                    | _1                | _2   |
|-----------------------|-------------------|------|
| Exercises in Futility | Mgla              | 5.0  |
| Reflektor             | Arcade Fire       | 4.65 |
| Vicious Delicious     | Infected Mushroom | 4.5  |

### Metal_Albums

```sql
SELECT * FROM Best_Albums WHERE _1 = 'Mgla'
```
| _0                    | _1   | _2  |
|-----------------------|------|-----|
| Exercises in Futility | Mgla | 5.0 |

## Produce

| Produce_Name | Type  |
|--------------|-------|
| Apple        | Fruit |
| Potato       | Tuber |
| Orange       | Fruit |

```sql
SELECT Produce_Name FROM Produce WHERE Type = 'Fruit'
ORDER BY Produce_Name DESC;
```
| _0     |
|--------|
| Orange |
| Apple  |
