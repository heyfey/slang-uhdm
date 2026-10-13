// § ifaceHcOpSelByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] ck, input logic a, output logic o);
  ifc u [2] (.clk(ck[1] & a));
  assign o = u[0].sig[0];
endmodule
