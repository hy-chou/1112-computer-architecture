.globl __start

.rodata
    msg0: .string "This is HW1-1: T(n) = 4T(n/2) + 2n + 7, T(1) = 5\n"
    msg1: .string "Enter a number: "
    msg2: .string "The result is: "

.text


__start:
  # Prints msg0
    addi a0, x0, 4
    la a1, msg0
    ecall

  # Prints msg1
    addi a0, x0, 4
    la a1, msg1
    ecall

  # Reads an int
    addi a0, x0, 5
    ecall

################################################################################ 
  # Write your main function here. 
  # Input n is in a0. You should store the result T(n) into t0
  # HW1-1 T(n) = 4T(n/2) + 2n + 7, T(1) = 5, round down the result of division
  # ex. addi t0, a0, 1

                             # a0 = n
main:
    jal t_func               # a0 = T(n)

    mv t0, a0                # t0 = T(n)
    beq zero, zero, main_end

t_func:
    addi sp, sp, -4
    sw ra, 0(sp)

    li t6, 2                 # t6 = 2
    bge a0, t6, core         # if (n >= 2) goto core
    li a0, 5                 # else a0 = 5
    j t_func_end
core:                        # n >= 2
    addi sp, sp, -4
    sw a0, 0(sp)

    srli a0, a0, 1           # a0 = n // 2
    jal t_func               # a0 = T(n // 2)
    mv t0, a0                # t0 = T(n // 2)

    lw a0, 0(sp)             # a0 = n
    addi sp, sp, 4

    slli t0, t0, 2           # t0 = 4 * T(n // 2)
    add t0, t0, a0           # t0 = 4 * T(n // 2) + n
    add t0, t0, a0           # t0 = 4 * T(n // 2) + 2 * n
    addi t0, t0, 7           # t0 = 4 * T(n // 2) + 2 * n + 7
    mv a0, t0                # a0 = 4 * T(n // 2) + 2 * n + 7
t_func_end:
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

main_end:
################################################################################

result:
  # Prints msg2
    addi a0, x0, 4
    la a1, msg2
    ecall

  # Prints the result in t0
    addi a0, x0, 1
    add a1, x0, t0
    ecall
    
  # Ends the program with status code 0
    addi a0, x0, 10
    ecall