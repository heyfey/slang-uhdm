// § genConnTernSysActual315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic a, input logic s, output logic o);
  ifc v (.clk(a));
  if (1) begin : g
    child c0 (.clk(s ? v.sig[0] : a), .o(o));
  end
endmodule
