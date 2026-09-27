package p;
typedef logic signed [12-1:0] imm_i_t;
typedef imm_i_t imm_l_t;
endpackage
module top import p::*; (input imm_l_t a, output logic [11:0] o);
  assign o = a;
endmodule
