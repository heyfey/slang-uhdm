// § ifaceHcIdxSelByInst317
interface ifc #(parameter int W = 1) (input logic clk);
  logic [W-1:0] sig;
endinterface
module top (input logic [3:0] ck, input logic [1:0] k, output logic o);
  ifc #(.W(2)) u (.clk(ck[k[0]] & ck[1]));
  assign o = u.sig[0];
endmodule
