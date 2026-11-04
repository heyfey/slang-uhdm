// § ifaceHcIdxSelByInst317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module tgt (input logic [3:0] ck, input logic [1:0] k, input logic a, output logic o);
  assign o = a;
endmodule
bind tgt ifc u (.clk(ck[k[0]] | a));
module top (input logic [3:0] ck, input logic [1:0] k, input logic [2:0] s, input logic [1:0][1:0] m, input logic a, output logic o);
  tgt t (.ck(ck), .k(k), .a(a), .o(o));
endmodule
