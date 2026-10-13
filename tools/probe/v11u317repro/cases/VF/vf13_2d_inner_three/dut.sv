// § nestSelChainName317v
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0][1:0] m, input logic [1:0] k, input logic [1:0] j, input logic a, output logic o);
  ifc u (.clk(m[k[j[0]]][1] & a));
  assign o = u.sig[0];
endmodule
