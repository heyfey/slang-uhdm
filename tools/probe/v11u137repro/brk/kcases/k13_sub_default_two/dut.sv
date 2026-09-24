// § structParamPathBaseAtMember137
package p;
  typedef struct packed { int W; int D; } cfg_t;
endpackage
module sub #(parameter p::cfg_t CFG = '{W: 4, D: 2})(output logic o);
  logic [CFG.W-1:0] x;
  logic [CFG.D-1:0] y;
  assign x = '1;
  assign y = '0;
  assign o = x[0] ^ y[0];
endmodule
module top(output logic o1, o2);
  sub u1(.o(o1));
  sub u2(.o(o2));
endmodule
