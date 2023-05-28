.globl __start

.rodata
    msg0: .string "This is HW1-2: \n"
    msg1: .string "Plaintext:  "
    msg2: .string "Ciphertext: "
.text

################################################################################
  # print_char function
  # Usage: 
  #     1. Store the beginning address in x20
  #     2. Use "j print_char"
  #     The function will print the string stored from x20 
  #     When finish, the whole program with return value 0

print_char:
    addi a0, x0, 4
    la a1, msg2
    ecall
    
    add a1,x0,x20
    ecall

  # Ends the program with status code 0
    addi a0,x0,10
    ecall
    
################################################################################

__start:
  # Prints msg
    addi a0, x0, 4
    la a1, msg0
    ecall

    la a1, msg1
    ecall
    
    addi a0,x0,8
    li a1, 0x10130
    addi a2,x0,2047
    ecall
    
  # Load address of the input string into a0
    add a0,x0,a1

################################################################################ 
  # Write your main function here. 
  # a0 stores the begining Plaintext
  # Do store 66048(0x10200) into x20 
  # ex. j print_char

                            # a0 = (char *)src
main:
    li t0, 66048            # t0 = (chat *)dst
    li t3, 48               # ctr = '0'
    li s2, 120              # s2 = 'x'
    li s1, 32               # s1 = ' '
    li s0, 10               # s0 = '\n'

core:
    lb t1, 0(a0)            # t1 = *src

h_nl:
    bne t1, s0, h_sp        # if (*src != '\n') goto h_sp
    sb s0, 0(t0)            # *dst = '\n'
    sb zero, 1(t0)          # *(dst+1) = '\0'
    j main_end
h_sp:
    bne t1, s1, h_abc        # if (*src != ' ') goto h_abc
    sb t3, 0(t0)            # *dst = ctr
    addi t3, t3, 1          # ctr = ctr + 1
    j core_end
h_abc:
    bge t1, s2, h_xyz       # if (*src >= 'x') goto h_xyz
    addi t2, t1, 3          # t2 = *src + 3
    sb t2, 0(t0)            # *dst = *src + 3
    j core_end
h_xyz:
    addi t2, t1, -23        # t2 = *src - 23
    sb t2, 0(t0)            # *dst = *src - 23

core_end:
    addi t0, t0, 1          # dst = dst + 1
    addi a0, a0, 1          # src = src + 1
    j core

main_end:
    li x20, 66048
    j print_char
################################################################################

