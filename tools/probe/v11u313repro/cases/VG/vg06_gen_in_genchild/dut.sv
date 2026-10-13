// § genIfaceHcInnerRefUnbound313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module mid (input logic [1:0] ck, input logic a, output logic o);
  if (1) begin : h
    ifc u (.clk(ck[1] & a));
    child c0 (.p(u), .o(o));
  end
endmodule
module top (input logic [1:0] ck, input logic a, output logic o);
  if (1) begin : g
    mid m (.ck(ck), .a(a), .o(o));
  end
endmodule
