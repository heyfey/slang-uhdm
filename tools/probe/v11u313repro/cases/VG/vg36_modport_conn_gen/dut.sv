// § genIfaceHcInnerRefUnbound313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module top (input logic a, input logic b, output logic o);
  if (1) begin : g
    ifc u (.clk(a | b));
    child c0 (.p(u.mp), .o(o));
  end
endmodule
