// § genCallArgLocalKeepsBind315v
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] a, output logic o);
  if (1) begin : g
    logic [1:0] l;
    assign l = a;
    ifc u (.clk($countones(l) == $countones(a)));
  end
  assign o = g.u.sig[0];
endmodule
