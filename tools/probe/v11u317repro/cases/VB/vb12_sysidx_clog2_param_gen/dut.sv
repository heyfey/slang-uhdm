// § genSysArgInnerUnbound317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top #(parameter int P = 4) (input logic [3:0] ck, input logic a, output logic o);
  if (1) begin : g
    ifc u (.clk(ck[$clog2(P)] | a));
  end
  assign o = g.u.sig[0];
endmodule
