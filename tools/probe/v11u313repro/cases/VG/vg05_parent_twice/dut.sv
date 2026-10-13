// § genIfaceConnGenScopeName313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module mid (input logic [1:0] ck, output logic o);
  if (1) begin : g
    ifc u (.clk(ck[1]));
    child c0 (.p(u), .o(o));
  end
endmodule
module top (input logic [1:0] ck, output logic [1:0] o);
  mid m0 (.ck(ck), .o(o[0]));
  mid m1 (.ck(~ck), .o(o[1]));
endmodule
