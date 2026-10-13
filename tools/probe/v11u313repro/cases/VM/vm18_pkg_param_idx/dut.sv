// § ifaceHcSelNamedByInst313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
package pk;
  localparam int I = 1;
endpackage
module top (input logic [1:0] ck, output logic o);
  ifc u (.clk(ck[pk::I]));
  child c0 (.p(u), .o(o));
endmodule
