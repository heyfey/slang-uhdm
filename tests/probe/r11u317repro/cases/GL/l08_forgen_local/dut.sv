// § genIfaceInnerLocalKeepsBind317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] a, output logic o);
  for (genvar i = 0; i < 2; i++) begin : g
    logic l;
    assign l = a[i];
    ifc u (.clk(l & a[0]));
  end
  assign o = a[1];
endmodule
