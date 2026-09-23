package p1;
  typedef enum logic [6:0] { OP_A = 7'h37, OP_B = 7'h17 } op_e;
  parameter logic [31:0] INSN_A = { 25'h?, {OP_A} };
  parameter logic [31:0] INSN_B = { 17'h?, 3'b000, 5'h?, {OP_B} };
endpackage
module dut (input logic [31:0] i, output logic [1:0] o);
  import p1::*;
  always_comb begin
    o = 2'd0;
    unique casez (i)
      INSN_A: o = 2'd1;
      INSN_B: o = 2'd2;
      default: o = 2'd3;
    endcase
  end
endmodule
