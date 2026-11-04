// § castTsInIdxNamedByChain317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
typedef logic [1:0] idx_t;
module top (input logic [3:0] ck, input logic [2:0] s, output logic o);
  ifc u (.clk(ck[idx_t'(s)] & ck[0]));
  assign o = u.sig[0];
endmodule
