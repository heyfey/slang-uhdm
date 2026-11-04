// § structParamPathBaseAtMember137
package p;
  typedef struct packed { int W; } cfg_t;
  parameter cfg_t CFG = '{W: 4};
endpackage
module top(output logic o);
  import p::*;
  logic [CFG.W-1:0] x;
  if (CFG.W > 2) begin : g
    assign x = '1;
  end
  assign o = x[0];
endmodule
