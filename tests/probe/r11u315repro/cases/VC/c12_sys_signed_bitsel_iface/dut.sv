// § genConnTernSysActual315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top (input logic [1:0] a, output logic o);
  if (1) begin : g
    ifc u (.clk($signed(a[1])));
    assign o = u.sig[0];
  end
endmodule
