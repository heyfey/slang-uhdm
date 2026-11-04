// § nestSelChainName317v
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, input logic [3:0] k, input logic [2:0] s, input logic a, output logic o);
  ifc u (.clk(ck[k[2'(s)]] | a));
  assign o = u.sig[0];
endmodule
