// § genConnTernSysActual315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
interface outer (input logic a, input logic b, input logic s);
  if (1) begin : h
    ifc u (.clk(s ? a : b));
  end
  logic w;
  assign w = h.u.sig[0];
endinterface
module top (input logic a, input logic b, input logic s, output logic o);
  outer ou (.a(a), .b(b), .s(s));
  assign o = ou.w;
endmodule
