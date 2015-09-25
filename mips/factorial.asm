# CS 3650 Homework 1
# Pete MacLellan
# This MIPS assembly program prompts the user to enter a positive integer
# and then computes the factorial of that number, displays it to the
# screen, and then repeats the process indefinitely.
#
# Note: Sometimes this behaves a little strangely and when you hit RUN
# 	it doesn't move the cursor to the prompt so you get an error.
#	Ususally restarting works and then your integer is read from
#	the Run I/O field correctly.

	.data
prompt: .asciiz "\n\nPositive integer:\n"
result: .asciiz "The factorial of that number is "
	.text
start:	la $a0, prompt	       # set prompt message as argument to print
	li $v0, 4	       # specify Print String syscall
	syscall		       # print prompt message
	li $v0, 5	       # syscall for "read integer"
	syscall		       # read integer to get factorial of
	move $a0, $v0	       # set received integer as arg
	jal fact	       # fact(x)
	
	move $t1, $v0	       # store result in temp reg
	la $a0, result	       # set result message to print
	li $v0, 4	       # specify Print String syscall
	syscall
	move $a0, $t1	       # move factorial result back from temp
	li $v0, 36	       # specify Print Integer Unsigned syscall
	syscall
again:	j start		       # loops back to the start to ask for new integer

exit:	li $v0, 10	       # syscall for exit **this will never happen**
	syscall

fact:   addi $sp, $sp, -32     # push stack
	sw $ra, 0($sp)         # put old_ra in call frame
	move $t5, $a0          # copy arg to local

	blt $t5, 1, base       # handle base case (x==0)

	addi $a0, $t5, -1      # decrement for loop
	sw $t5, 4($sp)         # store temp var to memory
	jal fact               # recurse -> factorial(x-1)
	
	lw $t5, 4($sp)         # restore temp var from memory
	move $t6, $v0          # answer from above
	mulu $t7, $t5, $t6     # t7 = x * factorial(x-1) **unsigned**

epilog: move $v0, $t7          # return value from temp
	lw $ra, 0($sp)         # get old_ra from call frame
	addi $sp, $sp, 32      # pop stack
	jr $ra                 # return to previous call frame, skip base

base:   addi $t7, $zero, 1     # set "return value" to 1
	j epilog               # clean up and return