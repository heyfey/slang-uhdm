// § genIfaceInnerLocalKeepsBind317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, output logic o);
  if (1) begin
    logic l;
    assign l = ~a;
    ifc u (.clk(a & l));
  end
  assign o = a;
endmodule
