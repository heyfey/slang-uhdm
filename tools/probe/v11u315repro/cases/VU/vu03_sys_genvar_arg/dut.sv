// § genIfaceHcCallArgUnbound315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] a, output logic o);
  for (genvar i = 0; i < 2; i++) begin : g
    ifc u (.clk($signed(a[i])));
  end
  assign o = g[0].u.sig[0];
endmodule
