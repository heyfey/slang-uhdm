// § ifaceHcVarSelByInst317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0][1:0] m, input logic [1:0] k, input logic s, output logic o);
  ifc u (.clk(m[k[0]][s] | m[0][0]));
  assign o = u.sig[0];
endmodule
