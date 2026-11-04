// § ifaceHcOpSelByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, output logic o);
  ifc u (.clk(ck[1:0] == 2'b01));
  assign o = u.sig[0];
endmodule
