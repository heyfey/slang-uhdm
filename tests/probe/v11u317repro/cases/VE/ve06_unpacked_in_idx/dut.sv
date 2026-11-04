// § ifaceHcIdxSelByInst317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, input logic [1:0] mem [2], output logic o);
  ifc u (.clk(ck[mem[1]] ^ ck[0]));
  assign o = u.sig[0];
endmodule
