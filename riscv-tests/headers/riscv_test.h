#ifndef _ENV_PICORV32_TEST_H
#define _ENV_PICORV32_TEST_H

#ifndef TEST_FUNC_NAME
#  define TEST_FUNC_NAME mytest
#  define TEST_FUNC_TXT "mytest"
#  define TEST_FUNC_RET mytest_ret
#endif

#define RVTEST_RV32U
#define TESTNUM x28

#define RVTEST_CODE_BEGIN		\
	.text;				\
	.global TEST_FUNC_NAME;		\
	.global TEST_FUNC_RET;		\
	.global uart_putchar;	\
TEST_FUNC_NAME:				\
	la sp, _stack_top;		\
	sw ra, (sp);			\
	lui	a3,%hi(.test_name);	\
	addi a3,a3,%lo(.test_name);\
.prname_next:				\
	lb	a0,0(a3);			\
	beq	a0,zero,.prname_done;\
	jal uart_putchar;		\
	addi	a3,a3,1;		\
	jal	zero,.prname_next;	\
.prname_done:				\
	addi	a0,zero,' ';	\
	jal uart_putchar;		\
	addi	a0,zero,'-';	\
	jal uart_putchar;		\
	addi	a0,zero,'>';	\
	jal uart_putchar;		\
	addi	a0,zero,' ';	\
	jal uart_putchar;		\
	lw ra, (sp);			\

#define RVTEST_PASS			\
	la sp, _stack_top;		\
	sw ra, (sp);			\
	addi a0, zero, 'P';		\
	jal uart_putchar;		\
	addi a0, zero, 'A';		\
	jal uart_putchar;		\
	addi a0, zero, 'S';		\
	jal uart_putchar;		\
	addi a0, zero, 'S';		\
	jal uart_putchar;		\
	addi a0, zero, '\n';	\
	jal uart_putchar;		\
	lw ra, (sp);			\
	jal zero, TEST_FUNC_RET;


#define RVTEST_FAIL			\
	la sp, _stack_top;		\
	sw ra, (sp);			\
	addi a0, zero, 'F';		\
	jal uart_putchar;		\
	addi a0, zero, 'A';		\
	jal uart_putchar;		\
	addi a0, zero, 'I';		\
    jal uart_putchar;		\
	addi a0, zero, 'L';		\
    jal uart_putchar;		\
	addi a0, zero, '\n';	\
	jal uart_putchar;		\
	lw ra, (sp);			\
	jal zero, TEST_FUNC_RET;

#define RVTEST_CODE_END
#define RVTEST_DATA_BEGIN             \
	.data;                            \
	.test_name :.ascii TEST_FUNC_TXT; \
	.byte 0x00;                       \
	.balign 4, 0;

#define RVTEST_DATA_END

#endif