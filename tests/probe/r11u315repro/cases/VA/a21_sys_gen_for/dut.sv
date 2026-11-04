// § genIfaceHcCallArgUnbound315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] a, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    ifc u (.clk($unsigned(a[i])));
    assign o[i] = u.sig[0];
  end
endmodule
