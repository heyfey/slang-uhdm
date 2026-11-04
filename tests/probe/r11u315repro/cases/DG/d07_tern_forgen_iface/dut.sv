// § genConnTernSysActual315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic [1:0] a, input logic s, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    ifc u (.clk(s ? a[0] : a[1]));
    assign o[i] = u.sig[0];
  end
endmodule
