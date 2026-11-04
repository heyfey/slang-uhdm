package p;
typedef logic signed [12-1:0] imm_i_t;
typedef imm_i_t imm_l_t;
typedef struct packed { imm_l_t imm; logic x; } ctl_t;
endpackage
module top import p::*; (input ctl_t a, output logic [11:0] o);
  assign o = a.imm;
endmodule
