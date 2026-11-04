// § structParamPathBaseAtMember137
package p;
  typedef struct packed { int W; } cfg_t;
endpackage
module sub #(parameter p::cfg_t CFG = '{W: 4})(output logic o);
  logic [CFG.W-1:0] x;
  assign x = '1;
  assign o = x[0];
endmodule
module top(output logic o);
  logic CFG;
  assign CFG = 1'b1;
  sub u(.o(o));
endmodule
