// § genConnTernSysActual315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic [3:0] a, input logic s, output logic [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 2; j++) begin : h
      child c0 (.clk(s ? a[i] : a[j+2]), .o(o[i*2+j]));
    end
  end
endmodule
