// § genIfaceInnerLocalKeepsBind317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top #(parameter P = 0) (input logic a, output logic o);
  if (P) begin : g
    assign o = a;
  end else begin : e
    logic l;
    assign l = a;
    ifc u (.clk(l ^ a));
    assign o = u.sig[0];
  end
endmodule
