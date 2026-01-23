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
