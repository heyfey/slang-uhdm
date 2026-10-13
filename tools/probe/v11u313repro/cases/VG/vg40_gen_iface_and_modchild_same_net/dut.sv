// § genIfaceHcInnerRefUnbound313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module m2 (input logic [1:0] a, output logic o);
  assign o = a[0];
endmodule
module top (input logic [1:0] ck, input logic s, output logic o, output logic o2);
  if (1) begin : g
    m2 x (.a(ck), .o(o2));
    ifc u (.clk(ck[s]));
    child c0 (.p(u), .o(o));
  end
endmodule
