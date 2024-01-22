    MOV R6, stack_begin
    LDR R6, [R6]       // Initialize stack pointer
    MOV R4, result     // R4 contains address of result
    MOV R3, #0
    STR R3, [R4]       // result = 0
    MOV R0, #1         // R0 contains first parameter
    MOV R1, #5         // R1 contains second parameter
    MOV R2, #9         // R2 contains third parameter
    MOV R3, #20        // R3 contains fourth parameter
    BL  leaf_example   // Call leaf_example(1,5,9,20) (R7 = 16'd10)
    STR R0, [R4]       // result = leaf_example(1,5,9,20)

    MOV R7, #10        // Load 10 into R7 for comparison
    CMP R0, R7         // Compare R0 with 10 (in R7) (status = N)
    BEQ equal_label    // Branch if equal to 10 (Not happening)
    BNE not_equal_label // Branch if not equal to 10

less_or_equal_label:
    MVN R2, R1         // Negate R1 and store in R2
    BX R7              // Return to the caller

equal_label:
    MOV R3, #1         // If equal, set R3 to 1
    B end_label        // Jump to end

not_equal_label:
    MOV R3, #0         // If not equal, set R3 to 0
    // More branching examples
    CMP R3, R0
    BLE less_or_equal_label // Branch if R3 <= R0 (won't happen here)
    BLT less_than_label     // Branch if R3 < R0 (won't happen here)
    B equal_label

less_than_label:
    AND R2, R1, R0     // Example AND operation (won't happen here)
    B end_label        // Jump to end


end_label:
    HALT               // Halt the processor

leaf_example:
    STR R4, [R6]       // Save R4 for use afterwards
    STR R5, [R6, #-1]  // Save R5 for use afterwards
    ADD R4, R0, R1     // R4 = g + h
    ADD R5, R2, R3     // R5 = i + j
    MVN R5, R5         // R5 = ~(i + j)
    ADD R4, R4, R5     // R4 = (g + h) + ~(i + j)
    MOV R5, #1
    ADD R4, R4, R5     // R4 = (g + h) - (i + j)
    MOV R0, R4         // R0 = return value (g + h) - (i + j)
    LDR R5, [R6, #-1]  // Restore saved contents of R5
    LDR R4, [R6]       // Restore saved contents of R4
    BX  R7             // Return control to caller (PC = 16'd10)

stack_begin:
    .word 0xFF
result:
    .word 0xCCCC
