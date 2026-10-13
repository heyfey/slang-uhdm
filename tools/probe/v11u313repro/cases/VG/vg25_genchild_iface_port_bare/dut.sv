// § genIfaceParentAtBirth313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module c2 (ifc p, output logic o);
  assign o = p.sig[0];
endmodule
module top (input logic [1:0] ck, output logic o);
  if (1) begin : g
    ifc u (.clk(ck[0]));
    c2 c (.p(u), .o(o));
  end
endmodule
