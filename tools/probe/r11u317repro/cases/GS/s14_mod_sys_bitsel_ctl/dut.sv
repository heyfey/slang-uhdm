// § genSysArgInnerUnbound317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] ck, input logic s, output logic o);
  ifc u (.clk($signed(ck[s])));
  assign o = u.sig[0];
endmodule
