// § genCallArgInnerBlockOnly317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, output logic o);
  for (genvar i = 0; i < 2; i++) begin : g
    logic l;
    assign l = a;
    if (1) begin : h
      ifc u (.clk($unsigned(l)));
    end
  end
  assign o = g[1].h.u.sig[0];
endmodule
