// § genIfaceParentAtBirth313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module top (input logic a, output logic o, output logic o2);
  if (1) begin : g
    ifc u (.clk(a));
    child c0 (.p(u), .o(o));
  end
  if (1) begin : h
    assign o2 = g.u.sig[1] | g.u.clk;
  end
endmodule
