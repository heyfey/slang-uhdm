// § genConnTernSysActual315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic b, input logic s, output logic o);
  if (1) begin : g
    ifc u [2] (.clk(s ? a : b));
  end
  assign o = g.u[0].sig[0];
endmodule
