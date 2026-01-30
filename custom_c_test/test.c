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

__attribute__((noinline))
int test_mul_basic(void)
{
    volatile int a = 7;
    volatile int b = 6;
    volatile int c = a * b;
    return (c == 42) ? 0 : 1;
}

__attribute__((noinline))
int test_mulhsu(void)
{
    int a = -5;
    unsigned b = 4;

    long long prod =
        (long long)a * (unsigned long long)b;

    int expected = (int)(prod >> 32);

    int hw;
    asm volatile ("mulhsu %0, %1, %2"
                  : "=r"(hw)
                  : "r"(a), "r"(b));

    return (hw == expected) ? 0 : 1;
}


__attribute__((noinline))
int test_mulh(void)
{
    int a = -10;
    int b = 3;

    long long prod = (long long)a * (long long)b;
    int expected = (int)(prod >> 32);

    int hw;
    asm volatile ("mulh %0, %1, %2"
                  : "=r"(hw)
                  : "r"(a), "r"(b));

    return (hw == expected) ? 0 : 1;
}

__attribute__((noinline))
int test_mulhu(void)
{
    unsigned a = 0xFFFFFFFFu;
    unsigned b = 2;

    unsigned long long prod =
        (unsigned long long)a * (unsigned long long)b;

    unsigned expected = (unsigned)(prod >> 32);

    unsigned hw;
    asm volatile ("mulhu %0, %1, %2"
                  : "=r"(hw)
                  : "r"(a), "r"(b));

    return (hw == expected) ? 0 : 1;
}


__attribute__((noinline))
int test_div(void)
{
    volatile int a = -20;
    volatile int b = 5;
    volatile int c = a / b;
    return (c == -4) ? 0 : 1;
}

__attribute__((noinline))
int test_divu(void)
{
    volatile unsigned a = 20;
    volatile unsigned b = 4;
    volatile unsigned c = a / b;
    return (c == 5) ? 0 : 1;
}

__attribute__((noinline))
int test_div_zero(void)
{
    volatile int a = 123;
    volatile int b = 0;
    volatile int c = a / b;
    return (c == -1) ? 0 : 1;
}

__attribute__((noinline))
int test_div_overflow(void)
{
    volatile int a = 0x80000000;
    volatile int b = -1;
    volatile int c = a / b;
    return (c == a) ? 0 : 1;
}

__attribute__((noinline))
int test_rem(void)
{
    volatile int a = -20;
    volatile int b = 6;
    volatile int c = a % b;
    return (c == -2) ? 0 : 1;
}

__attribute__((noinline))
int test_rem_zero(void)
{
    volatile int a = 123;
    volatile int b = 0;
    volatile int c = a % b;
    return (c == a) ? 0 : 1;
}

__attribute__((noinline))
int test_remu(void)
{
    volatile unsigned a = 20;
    volatile unsigned b = 6;
    volatile unsigned c = a % b;
    return (c == 2) ? 0 : 1;
}
#include <stdint.h>
void uart_puthex(uint32_t val)
{
    uart_puts("0x");

    int shift = 28;
    for (int i = 0; i < 8; i++)
    {
        uint32_t nibble = (val >> shift) & 0xF;
        uart_putc(nibble < 10 ? ('0' + nibble) : ('A' + nibble - 10));
        shift -= 4;
    }
}

static inline int get_insts_count(void)
{
    return *(volatile int*)0xFFFFFF10;
}

static inline int get_jump_insts_count(void)
{
    return *(volatile int*)0xFFFFFF20;
}

static inline int get_mispred_count(void)
{
    return *(volatile int*)0xFFFFFF30;
}


int main(void)
{
    int err = 0;

    int start = get_insts_count();

    volatile int a = 0x00000014;
    volatile int b = 0xfffffffa;
    volatile int c = a / b;

    uart_puts("ERR=");
    uart_puthex(c);
    uart_putc('\n');

    int end = get_insts_count();
    int count = end - start;
    uart_puthex(count);

    // return 0 if ALL tests passed
    return c;
}
