// § ifaceHcCallArgByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] ck, output logic o);
  ifc u (.clk($signed(ck[1])));
  assign o = u.sig[0];
endmodule
