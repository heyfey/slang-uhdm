// § genConnTernSysActual315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic [1:0] a, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    child c (.clk($unsigned(a[i])), .o(o[i]));
  end
endmodule
