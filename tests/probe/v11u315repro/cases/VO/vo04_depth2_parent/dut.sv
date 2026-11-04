// § ifaceHcOpSelByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module mid (input logic [1:0] ck, input logic s, output logic o);
  ifc u (.clk(ck[s] ^ ck[0]));
  assign o = u.sig[0];
endmodule
module top (input logic [1:0] ck, input logic s, output logic o);
  mid m (.ck(ck), .s(s), .o(o));
endmodule
