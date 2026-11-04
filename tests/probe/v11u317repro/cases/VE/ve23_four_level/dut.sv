// § nestSelChainName317v
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, input logic [1:0] k, input logic [1:0] j, input logic [1:0] i2, input logic a, output logic o);
  ifc u (.clk(ck[k[j[i2[0]]]] | a));
  assign o = u.sig[0];
endmodule
