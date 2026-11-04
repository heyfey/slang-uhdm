// § ifaceHcCallArgByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, output logic o);
  ifc u (.clk($unsigned($signed(a))));
  assign o = u.sig[0];
endmodule
