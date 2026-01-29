void uart_putc(char c) // Write single character
{
    // volatile pointer so compiler does not optimze away memory access
    volatile char *uart_tx = (char *)0xFFFF0000;
    *uart_tx = c;
}

// Writes null terminated string to UART
void uart_puts(const char *str)
{
    while (*str)
    {
        uart_putc(*str++);
    }
}

__attribute__((noinline))
int branch_always_taken(int n)
{
    int sum = 0;
    for (int i = 0; i < n; i++)
    {
        if (i >= 0)   // always taken
            sum++;
    }
    return sum;
}

__attribute__((noinline))
int branch_never_taken(int n)
{
    int sum = 0;
    for (int i = 0; i < n; i++)
    {
        if (i < 0)    // never taken
            sum++;
    }
    return sum;
}



__attribute__((noinline))
int branch_alternating(int n)
{
    int sum = 0;
    for (int i = 0; i < n; i++)
    {
        if (i & 1)    // T, NT, T, NT...
            sum++;
    }
    return sum;
}

__attribute__((noinline))
int loop_branch(int n)
{
    int i = 0;
    while (i < n)
    {
        i++;
    }
    return i;
}

__attribute__((noinline))
int correlated_branch(int n)
{
    int sum = 0;
    int last = 0;

    for (int i = 0; i < n; i++)
    {
        if (last)
        {
            sum++;
            last = 0;
        }
        else
        {
            last = 1;
        }
    }
    return sum;
}


__attribute__((noinline))
int fib_debug(int n)
{
    if (n < 2)
        return n;

    int a = fib_debug(n-1);  // first recursive call
    int b = fib_debug(n-2);  // second recursive call
    return a + b;
}

int main(void)
{
    uart_puts("Start\n");
    int a = fib_debug(4);
    uart_puts("End\n");
    return a;
}
