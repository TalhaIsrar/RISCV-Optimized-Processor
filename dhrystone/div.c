int __divsi3(int a, int b)
{
    if (b == 0)
        return 0; // Handle division by zero
    int quot = 0;
    int sign = 1;
    if (a < 0)
    {
        a = -a;
        sign = -sign;
    }
    if (b < 0)
    {
        b = -b;
        sign = -sign;
    }
    while (a >= b)
    {
        a -= b;
        quot++;
    }
    return sign * quot;
}