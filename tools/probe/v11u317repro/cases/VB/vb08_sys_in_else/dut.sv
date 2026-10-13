// § genSysArgInnerUnbound317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top #(parameter int P = 0) (input logic [1:0] ck, input logic s, output logic o);
  if (P == 1) begin : g
    ifc u (.clk(ck[0]));
  end else begin : g
    ifc u (.clk($signed(ck[s]) | ck[0]));
  end
  assign o = g.u.sig[0];
endmodule
