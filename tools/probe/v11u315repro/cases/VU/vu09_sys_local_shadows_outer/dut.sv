// § genCallArgLocalKeepsBind315v
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, output logic o);
  if (1) begin : g
    logic a;
    assign a = 1'b1;
    ifc u (.clk($signed(a)));
  end
  assign o = g.u.sig[0];
endmodule
