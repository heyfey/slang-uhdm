// § genConnTernSysActual315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic a, output logic o);
  if (1) begin : g
    child c0 (.clk($signed(
                 a)), .o(o));
  end
endmodule
