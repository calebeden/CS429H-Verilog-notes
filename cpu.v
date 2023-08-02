module main;

    initial begin
        // Simulation details since in `initial`
        $dumpfile("cpu.vcd");
        $dumpvars(0, main);
    end

    /*********
     * Clock *
     *********/
    reg clock = 1;
    // Always = infinite loop, every always block runs in parallel
    always begin
        #1;
        // Blocking assignment = latch
        clock = ~clock;
    end

    /**********
     * Memory *
     **********/
    // Array of flip flops (same cheating as before)
    reg [15:0] mem [0:1023]; // 16x1024
    initial begin
        // Ask simulator to pre-populate mem from the given file
        // mem.hex starts initializing at bit 0 [from @0]
        // initializes the first 3 words then leaves the rest undefined
        // Undefined values will be tracked through the simulation
        $readmemh("mem.hex", mem);
    end

    /*************
     * Registers *
     *************/
    reg [15:0] regs [0:15];
    integer i;
    initial begin
        // for (i = 0; i < 16; i++) regs[i] = 0;
        for (i = 0; i < 16; i++) regs[i] = i+100;
    end
    // Hack for debugging in GTKWave - not good to actually include in synthesized design
    wire [15:0] r0 = regs[0];
    wire [15:0] r1 = regs[1];
    wire [15:0] r2 = regs[2];
    wire [15:0] r3 = regs[3];
    wire [15:0] r4 = regs[4];
    wire [15:0] r5 = regs[5];
    wire [15:0] r6 = regs[6];
    wire [15:0] r7 = regs[7];
    wire [15:0] r8 = regs[8];
    wire [15:0] r9 = regs[9];
    wire [15:0] r10 = regs[10];
    wire [15:0] r11 = regs[11];
    wire [15:0] r12 = regs[12];
    wire [15:0] r13 = regs[13];
    wire [15:0] r14 = regs[14];
    wire [15:0] r15 = regs[15];

    /******
     * PC *
     ******/
    reg [15:0] pc = 0;

    /*********
     * Fetch *
     *********/
    wire [15:0] ins = mem[pc[9:0]]; // Read port

    /**********
     * Decode *
     **********/
    wire [3:0] opcode = ins[15:12];
    wire [3:0] ra = ins[11:8];
    wire [3:0] rb = ins[7:4];
    wire [3:0] rt = ins[3:0];

    wire is_add = opcode == 1;
    wire is_unknown = ~is_add;

    /************
     * Operands *
     ************/
    wire [15:0] va = regs[ra];
    wire [15:0] vb = regs[rb];

    /***********
     * Execute *
     ***********/
    wire [15:0] result = is_add ? va + vb :
                        //  is_sub ? va - vb :
                         0;
    wire write_to_regs = is_add; // | is_sub | ...
    wire write_to_mem = 0; // when we have a str instr then this can be populated
    wire jump = 0; // when we have a jmp instr then this can be populated
    wire [15:0] target = jump ? result : pc + 1;

    always @(posedge clock) begin
        if (write_to_regs) regs[rt] <= result;
        pc <= target;
    end

    always @(negedge clock) begin
        if (is_unknown) $finish();
    end


endmodule