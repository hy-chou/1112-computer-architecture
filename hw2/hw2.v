module ALU #(
    parameter DATA_W = 32
)
(
    input                       i_clk,
    input                       i_rst_n,

    input                       i_valid,
    input [DATA_W - 1 : 0]      i_A,
    input [DATA_W - 1 : 0]      i_B,
    input [         2 : 0]      i_inst,

    output [2*DATA_W - 1 : 0]   o_data,
    output                      o_done
);
// Do not Modify the above part !!!

    // Parameters
    // Definition of states
    parameter S_IDLE = 4'd0;
    parameter S_ADD  = 4'd1;
    parameter S_SUB  = 4'd2;
    parameter S_AND  = 4'd3;
    parameter S_OR   = 4'd4;
    parameter S_SLT  = 4'd5;
    parameter S_SRA  = 4'd6;
    parameter S_MUL  = 4'd7;
    parameter S_DIV  = 4'd8;
    parameter S_OUT  = 4'd9;

    // Wires & Regs
    // Todo
    reg [3:0]              state, next_state;
    reg [5:0]              counter, next_counter;
    reg [2*DATA_W - 1 : 0] reg64_A;
    reg [DATA_W - 1 : 0]   reg32_B;
    reg [DATA_W - 1 : 0]   tmp32;
    reg                    tmp1;

    // Wire Assignments
    // Todo
    assign o_data = reg64_A;
    assign o_done = (state == S_OUT) ? 1'b1 : 1'b0;


    // CS (Current State)
    //// Todo: Sequential always block
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin  // active low asynchronous reset
            state <= S_IDLE;
            counter <= 0;
        end
        else begin
            state <= next_state;
            counter <= next_counter;
        end
    end


    // NL (Next-state Logic)
    //// Always Combination
    //// Todo: FSM
    always @(*) begin
        case (state)
            S_IDLE:
                if (i_valid) begin
                    case (i_inst)
                        3'd0: next_state = S_ADD;
                        3'd1: next_state = S_SUB;
                        3'd2: next_state = S_AND;
                        3'd3: next_state = S_OR;
                        3'd4: next_state = S_SLT;
                        3'd5: next_state = S_SRA;
                        3'd6: next_state = S_MUL;
                        3'd7: next_state = S_DIV;
                    endcase
                end
                else
                    next_state = state;
            S_ADD: next_state = S_OUT;
            S_SUB: next_state = S_OUT;
            S_AND: next_state = S_OUT;
            S_OR:  next_state = S_OUT;
            S_SLT: next_state = S_OUT;
            S_SRA: next_state = S_OUT;
            S_MUL: next_state = (counter == DATA_W - 1'b1) ? S_OUT : state;
            S_DIV: next_state = (counter == DATA_W - 1'b1) ? S_OUT : state;
            S_OUT: next_state = S_IDLE;
            default: next_state = state;
        endcase
    end

    // Todo: Counter
    always @(*) begin
        if (state == S_MUL || state == S_DIV)
            next_counter = counter + 1;
        else
            next_counter = 0;
    end


    // OL (Output Logic)
    // Todo: ALU output
    // Todo: Shift register
    always @(posedge i_clk) begin
        case (state)
            S_IDLE:
                begin
                    if (i_valid) begin
                        reg64_A = i_A;
                        reg32_B = i_B;
                    end
                end

            S_ADD:
                begin
                    tmp32 = reg64_A + reg32_B;
                    if ((reg64_A[DATA_W-1] == reg32_B[DATA_W-1]) && 
                        (reg64_A[DATA_W-1] != tmp32[DATA_W-1]))
                        reg64_A = (reg64_A[DATA_W-1] == 0) ?
                            64'h7FFF_FFFF : 64'h8000_0000;
                    else
                        reg64_A = tmp32;
                end
            S_SUB:
                begin
                    tmp32 = reg64_A - reg32_B;
                    if ((reg64_A[DATA_W-1] != reg32_B[DATA_W-1]) && 
                        (reg64_A[DATA_W-1] != tmp32[DATA_W-1]))
                        reg64_A = (reg64_A[DATA_W-1] == 0) ?
                            64'h7FFF_FFFF : 64'h8000_0000;
                    else
                        reg64_A = tmp32;
                end
            S_AND: reg64_A = reg64_A & reg32_B;
            S_OR:  reg64_A = reg64_A | reg32_B;
            S_SLT:
                begin
                    if (reg64_A[DATA_W-1] == reg32_B[DATA_W-1])
                        reg64_A = reg64_A[DATA_W-2:0] < reg32_B[DATA_W-2:0];
                    else
                        reg64_A = reg64_A[DATA_W-1] == 1;
                end
            S_SRA:
                begin
                    if (reg64_A[DATA_W-1] == 0)
                        tmp32 = reg64_A >> reg32_B;
                    else
                        tmp32 = ({32'hFFFF_FFFF, reg64_A[DATA_W-1:0]} >>> reg32_B);
                    reg64_A = tmp32;
                end

            S_MUL:
                begin
                    if (reg64_A[0] == 1)
                        {tmp1, tmp32} = reg64_A[2*DATA_W-1:DATA_W] + reg32_B;
                    else
                        {tmp1, tmp32} = reg64_A[2*DATA_W-1:DATA_W];
                    reg64_A = {tmp1, tmp32, reg64_A[DATA_W-1:1]};
                end
            S_DIV:
                begin
                    tmp32 = reg64_A[2*DATA_W-2:DATA_W-1];
                    if (tmp32 >= reg32_B)
                        reg64_A = {(tmp32 - reg32_B), reg64_A[DATA_W-2:0], 1'b1};
                    else
                        reg64_A = {reg64_A[2*DATA_W-2:0], 1'b0};
                end

            default: reg64_A = 64'h0123_4567_89AB_CDEF;
        endcase
    end
endmodule
