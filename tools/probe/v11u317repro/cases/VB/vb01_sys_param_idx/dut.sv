// § genSysArgInnerUnbound317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top #(parameter int P = 1) (input logic [3:0] ck, output logic o);
  if (1) begin : g
    ifc u (.clk($signed(ck[P])));
  end
  assign o = g.u.sig[0];
endmodule
