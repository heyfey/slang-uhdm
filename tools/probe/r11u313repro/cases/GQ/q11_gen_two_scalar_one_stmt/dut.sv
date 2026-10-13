// § ifaceHcSelNamedByInst313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module top (input logic [1:0] ck, output logic [1:0] o);
  if (1) begin : g
    ifc u (.clk(ck[0])), v (.clk(ck[1]));
    child c0 (.p(u), .o(o[0]));
    child c1 (.p(v), .o(o[1]));
  end
endmodule
