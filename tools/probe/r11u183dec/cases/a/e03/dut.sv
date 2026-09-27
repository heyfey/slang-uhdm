package p;
typedef logic signed [11:0] imm_i_t;
typedef imm_i_t imm_l_t;
endpackage
module top (output logic [11:0] o);
  p::imm_l_t v;
  assign o = v;
endmodule
