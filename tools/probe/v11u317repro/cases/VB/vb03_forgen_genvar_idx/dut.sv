// § genSysArgInnerUnbound317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] ck, input logic [1:0] k, output logic o);
  for (genvar i = 0; i < 2; i++) begin : g
    ifc u (.clk($signed(ck[k[i]])));
  end
  assign o = g[0].u.sig[0];
endmodule
