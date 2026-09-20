package q;
  typedef struct packed { logic opc; logic [1:0] c11; } opcode_t;
  typedef struct packed {
    logic [11:0] imm_11_0;
    logic [4:0]  rs1;
    logic [2:0]  funct3;
    logic [4:0]  rd;
    opcode_t     opcode;
  } op32_i_t;
endpackage
module c1 import q::*; (output logic [26:0] o);
  localparam op32_i_t A = op32_i_t'{imm_11_0: 12'h123, rs1: 5'd5, funct3: 3'd2, rd: 5'd9, opcode: '{opc: 1'b1, c11: 2'b11}};
  assign o = A;
endmodule
