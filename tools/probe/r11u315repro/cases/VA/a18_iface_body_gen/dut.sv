// § ifaceHcOpSelByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
interface outer (input logic [1:0] ck);
  if (1) begin : h
    ifc u (.clk(ck[1] & ck[0]));
  end
  logic w;
  assign w = h.u.sig[0];
endinterface
module top (input logic [1:0] ck, output logic o);
  outer ou (.ck(ck));
  assign o = ou.w;
endmodule
