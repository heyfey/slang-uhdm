// § ifaceHcIdxSelByInst317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, input logic [1:0] k, input logic [1:0] j, output logic o);
  ifc u (.clk(ck[k[j[0]]] | ck[0]));
  assign o = u.sig[0];
endmodule
