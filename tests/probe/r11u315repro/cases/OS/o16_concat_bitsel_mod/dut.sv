// § ifaceHcOpSelByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] ck, output logic [1:0] o);
  ifc u (.clk({ck[0]}));
  assign o = u.sig[1:0];
endmodule
