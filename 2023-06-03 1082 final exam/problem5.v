module ALU(ctrl, in_A, in_B, out);
    input [ 2:0] ctrl;
    input [31:0] in_A, in_B;
    output [31:0] out;

    // Todo
    reg [31:0] reg32_out;

    assign out = reg32_out;

    always @(*) begin
        case (ctrl)
            3'd0: reg32_out = in_A + in_B;
            3'd1: reg32_out = in_A < in_B;
            3'd2: reg32_out = in_A << in_B;
            3'd3: reg32_out = in_A >> in_B;
            3'd4: reg32_out = in_A >>> in_B;
            3'd5: reg32_out = in_A & in_B;
            3'd6: reg32_out = in_A | in_B;
            3'd7: reg32_out = in_A ^ in_B;
            default:  reg32_out = 32'h3141_5926;
        endcase
    end
endmodule
