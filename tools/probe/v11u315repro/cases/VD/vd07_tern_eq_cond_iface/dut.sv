// § genConnTernSysActual315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] k, input logic a, input logic b, output logic o);
  if (1) begin : g
    ifc u (.clk(k == 2'd1 ? a : b));
  end
  assign o = g.u.sig[0];
endmodule
