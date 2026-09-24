// § structParamPathBaseAtMember137
package p;
  typedef struct packed { int W; } cfg_t;
  parameter cfg_t CFG = '{W: 4};
endpackage
module top(output logic o);
  logic [p::CFG.W-1:0] x;
  assign x = '1;
  assign o = x[0];
endmodule
