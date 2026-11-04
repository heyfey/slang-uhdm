// § structParamPathBaseAtMember137
package p;
  typedef struct packed { int A; int B; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{A: 3, B: 2})(output logic o);
  logic [CFG.A+CFG.B-1:0] x;
  assign o = x[0];
endmodule
