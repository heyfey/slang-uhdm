// § genIfaceConnGenScopeName313
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic clk, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    ifc u (.clk(clk));
    assign o[i] = u.sig[0];
  end
endmodule
