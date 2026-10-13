// § ifaceHcSelNamedByInst313
interface ifc2 (input logic clk, input logic [3:0] d);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] ck, input logic [7:0] dd, input logic [1:0] s, output logic o);
  ifc2 u (ck[s], dd[s +: 4]);
  assign o = u.sig[0];
endmodule
