// § structParamPathBaseAtMember137
package p;
  typedef struct packed { int D; int W; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{D: 16, W: 4})(output logic o);
  logic [$clog2(CFG.D)-1:0] x;
  assign o = x[0];
endmodule
