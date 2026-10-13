// § genConnTernSysActual315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic [3:0] a, output logic o);
  if (1) begin : g
    child c (.clk($countones(a) == 1), .o(o));
  end
endmodule
