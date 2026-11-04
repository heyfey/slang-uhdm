// § genConnTernSysActual315
interface ifw (input logic [1:0] clk);
  logic [7:0] sig;
endinterface
module top (input logic a, input logic b, input logic c, input logic s, output logic o);
  if (1) begin : g
    ifw u (.clk({s ? a : b, c}));
  end
  assign o = g.u.sig[0];
endmodule
