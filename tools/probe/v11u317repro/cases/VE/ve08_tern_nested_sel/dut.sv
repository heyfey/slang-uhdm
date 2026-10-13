// § ifaceHcIdxSelByInst317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, input logic [1:0] k, input logic s, input logic a, output logic o);
  ifc u (.clk(s ? ck[k[0]] : a));
  assign o = u.sig[0];
endmodule
