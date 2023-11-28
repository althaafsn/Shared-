MOV r0, #20 // set to a specific address
MOV r1, #5 // mov value of 5 to r1
ADD r2, r1, r1

// MOV to mem
STR r1 [r0, #1] // Mem 0x0021 should be 5
STR r2 [r0] // Mem 0x0020 should be 10
MOV r3, #1
ADD r3, r3, r0
LDR r4 [r3] // should get 5
HALT



