// § genConnTernSysActual315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic s, output logic o);
  if (1) begin : g
    child c0 (.clk(s ? 1'b1 : 1'b0), .o(o));
  end
endmodule
