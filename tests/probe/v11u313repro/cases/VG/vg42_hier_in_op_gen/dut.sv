// § genIfaceHcInnerRefUnbound313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module sub (output logic x);
  assign x = 1'b1;
endmodule
module top (input logic a, output logic o);
  sub s (.x());
  if (1) begin : g
    ifc u (.clk(s.x & a));
    child c0 (.p(u), .o(o));
  end
endmodule
