// § ifaceHcIdxSelByInst317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, input logic [2:0] k, input logic s, output logic o);
  ifc u (.clk(ck[k[s+1]]));
  assign o = u.sig[0];
endmodule
