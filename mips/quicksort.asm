#  Pete MacLellan
#  CS3650: Computer Systems - Fall 2015
#  Homework 3 (extra credit): Quicksort

#  The following program first takes an array of 16 names and loads it into an
#  array of pointers (label: data).  This is then used to print the unsorted
#  list of names.  The array is then sorted using a quicksort algorithm and 
#  finally the list of names is printed again, sorted alphabetically.

              .text
main:         la $t0, array      # load start addr for list of names
              la $t1, data       # load start addr for pointer list
              sw $t0, 0($t1)     # store first name ptr in data[0]
              li $t2, 15         # counter for loading data[] with ptrs to array[]
load_loop:    addi $t0, $t0, 32  # increment pointer into array[]
              addi $t1, $t1, 4   # increment ptr in data[]
              sw $t0, 0($t1)     # store name ptr in data
              addi $t2, $t2, -1
              bne $t2, $zero, load_loop
              
              li $v0, 4          # syscall for print string
              la $a0, initial    # load addr of string to print
              syscall
              la $a0, data       # put pointer to data[] into arg 0
              la $t3, size
              lw $a1, 0($t3)     # put size into arg 1
              jal print_array
              la $a0, data       # char* a[]
              li $a1, 0          # first
              la $t4, size
              lw $t4, 0($t4)     # get size
              addi $a2, $t4, -1  # last =  size - 1  NEED TO PASS INT AND MULT BY 4 WITHIN FUNCTION
              jal quicksort
              la $a0, finished   # load string addr
              li $v0, 4          # print string
              syscall
              la $a0, data       # put pointer to data[] into arg 0
              la $t4, size
              lw $a1, 0($t4)     # put size into arg 1
              jal print_array
              li $v0, 10       #exit
              syscall


str_lt:      move $t0, $a0
             move $t1, $a1
             li $t2, '\0'        # load null terminator into temp
  for_loop:  lbu $t3, 0($t0)     # load char from name X
             lbu $t4, 0($t1)     # load char from name Y
             beq $t3, $t2, end   # break out of for loop if name ends
             beq $t4, $t2, end
             addi $t0, $t0, 1    # increment X char
             addi $t1, $t1, 1    # increment Y char
             beq $t3, $t4, for_loop # if chars match, keep looping
             slt $v0, $t3, $t4   # else, set return to X < Y
             jr $ra              # return, result in v0
             
  end:       sne $v0, $t4, $t2   # return 1 if Y != '\0'
             jr $ra
             
             

print_array:  move $t0, $a0      # move data[] ptr into temp
              move $t1, $a1      # move size into temp
              li $a0, '['
              li $v0, 11         # print char syscall
              syscall   
              li $t2, '\0'
              li $t3, 0          # counter variable
  data_loop:  li $a0, ' '        # print space between each name
              li $v0, 11
              syscall
              slt $t9, $t3, $t1  # check if counter < size
              beqz $t9, end_print # branch and return if counter > size
              lw $t4, 0($t0)     # load addr of next name
              addi $t0, $t0, 4   # point to next element in data[]
              addi $t3, $t3, 1   # increment counter      
  name_loop:  lbu $a0, 0($t4)    # load char to be printed
              beq $a0, $t2, data_loop # break if null term
              li $v0, 11         # syscall for print char
              syscall           
              addi $t4, $t4, 1   # point to next char in name
              j name_loop
  end_print:  li $a0,,']'
              li $v0, 11
              syscall
              jr $ra             # done printing array
              
quicksort:    addi $sp, $sp, -36 # create call frame
              sw $ra, 0($sp)     # store return address
              sw $s0, 4($sp)     # store s registers used in this function
              sw $s1, 8($sp)
              sw $s2, 12($sp)
              sw $s3, 16($sp)
              sw $s4, 20($sp)
              sw $s5, 24($sp)
              sw $s6, 28($sp)
              sw $s7, 32($sp)
              
              move $s0, $a0      # s0 points to start of data[] (DON'T CHANGE!)
              
              add $t0, $a1, $a2  # temp = first + last
              srl $t0, $t0, 1    # temp = [(first + last) / 2 ]
              sll $t0, $t0, 2    # t0 = temp * 4 bytes
              add $t1, $s0, $t0  # point to data[(first+last)/2]
              lw $s1, 0($t1)     # load element at ^^ (pivot)
                                 # s1 = x from C code
              move $s2, $a1      # s2 will hold first (DON'T CHANGE!)
              move $s3, $a2      # s3 will hold last  (DON'T CHANGE!)
              sll $s4, $s2, 2    # s4 = i * 4 bytes
              sll $s5, $s3, 2    # s5 = j * 4 bytes
  outer:     
             # while (str_lt(data[i], x)) i++ 
    inner1:  add $t2, $s0, $s4   # ptr to data[i]
             lw $t2, 0($t2)      # t2 holds value of data[i], points to array of chars (name)
             move $a0, $t2       # move into argument for str_lt
             move $a1, $s1       # second arg for str_lt -> x in given code
             jal str_lt          # compare data[i], x. Result in v0
             beqz $v0, inner2    # stop looping if data[i] > x
             addi $s4, $s4, 4    # increment i by 4 bytes
             j inner1         # continue looping
             
             # while (str_lt(x, data[j])) j--
    inner2:  add $t3, $s0, $s5   # ptr to data[j]
             lw $t3, 0($t3)      # t3 holds value of data[j], points to array of chars (name)
             move $a0, $s1       # first arg for str_lt -> x in given code
             move $a1, $t3       # move data[j] into arg for str_lt
             jal str_lt          # compare x, data[j]. Result in v0
             beqz $v0, checkij   # stop looping if data[j] > x
             addi $s5, $s5, -4   # decrement j by 4 bytes
             j inner2         # continue looping

    checkij: slt $t4, $s4, $s5   # from code: i < j  (opposite of i >= j)
             beqz $t4, recurse1  # break outer loop
             # swap data[i] and data[j]
             add $t5, $s0, $s4   # t5 is ptr to data[i]
             lw $t6, 0($t5)      # t6 holds data[i]
             add $t7, $s0, $s5   # t7 is ptr to data[j]
             lw $t8, 0($t7)      # t8 holds data[j]
             sw $t8, 0($t5)      # store data[j] into data[i]
             sw $t6, 0($t7)      # store data[i] into data[j]
             addi $s4, $s4, 4    # increment i by 4 bytes -> 'i++'
             addi $s5, $s5, -4   # decrement j by 4 bytes -> 'j--'
             j outer      # continue outer loop -> 'for(;;)'
 
  recurse1:  addi $s4, $s4, -4   # i-1 * 4 bytes
             srl $s6, $s4, 2     # divide by 4 to get index, not in bytes
             slt $t9, $s2, $s6   # first < i-1
             beqz $t9, recurse2  # don't recurse here if first >= i-1
             move $a0, $s0       # put ptr to start of data[] int arg0
             move $a1, $s2       # put first in arg1
             move $a2, $s6       # put i-1 in arg2
             jal quicksort       # RECURSE!
             
  recurse2:  addi $s5, $s5, 4    # j+1 * 4 bytes
             srl $s7, $s5, 2     # divide by 4 to get index, not in bytes
             slt $t0, $s7, $s3   # j+1 < last
             beqz $t0, finish    # don't recurse here if j+1 >= last
             move $a0, $s0       # put ptr to start of data[] int arg0
             move $a1, $s7       # put j+1 in arg1
             move $a2, $s3       # put last in arg2
             jal quicksort       # RECURSE!
             
  finish:    lw $ra, 0($sp)    # reload return address
             lw $s0, 4($sp)    # reload s registers overwritten by this function
             lw $s1, 8($sp)
             lw $s2, 12($sp)
             lw $s3, 16($sp)
             lw $s4, 20($sp)
             lw $s5, 24($sp)
             lw $s6, 28($sp)
             lw $s7, 32($sp)
             addi $sp, $sp, 36 # release call frame
             
             jr $ra             # return
             
#### Data Segment ####     
          .data
size:     .word 16   
          .align 5
initial:  .asciiz "The initial array is:\n"
          .align 5
finished: .asciiz "\nQuick sort is finished!\n"
          .align 5
array:    .asciiz "Joe"
          .align 5
          .asciiz "Jenny"
          .align 5
          .asciiz "Jill"
          .align 5
          .asciiz "John"
          .align 5
          .asciiz "Jeff"
          .align 5
          .asciiz "Joyce"
          .align 5
          .asciiz "Jerry"
          .align 5
          .asciiz "Janice"
          .align 5
          .asciiz "Jake"
          .align 5
          .asciiz "Jonna"
          .align 5
          .asciiz "Jack"
          .align 5
          .asciiz "Jocelyn"
          .align 5
          .asciiz "Jessie"
          .align 5
          .asciiz "Jess"
          .align 5
          .asciiz "Janet"
          .align 5
          .asciiz "Jane"
        
        .align 2
data:   .space 64  # 16 pointers to strings
        
