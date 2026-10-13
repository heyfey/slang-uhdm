// § ifaceHcOpSelByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
interface outer (input logic [1:0] ck);
  ifc u (.clk(ck[0] ^ ck[1]));
endinterface
module top (input logic [1:0] ck, output logic o);
  outer w (.ck(ck));
  assign o = w.u.sig[0];
endmodule
