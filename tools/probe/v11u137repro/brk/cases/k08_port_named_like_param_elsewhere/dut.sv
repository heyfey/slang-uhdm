// § structParamPathBaseAtMember137
package p;
  typedef struct packed { int W; } cfg_t;
endpackage
interface bus #(parameter int W = 2);
  logic [W-1:0] d;
endinterface
module sub #(parameter p::cfg_t CFG = '{W: 4})(bus CFGB, output logic o);
  logic [CFG.W-1:0] x;
  assign o = x[0] ^ CFGB.d[0];
endmodule
module top(output logic o);
  bus b();
  sub u(.CFGB(b), .o(o));
endmodule
