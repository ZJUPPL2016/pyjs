a = 1
b = a

while a < 10:
    a += b
    b = b * a

print(a, b)

if b > a:
    print(b - a)
