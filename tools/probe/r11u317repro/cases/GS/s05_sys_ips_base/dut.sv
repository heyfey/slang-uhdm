// § genSysArgInnerUnbound317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, input logic [1:0] s, output logic o);
  if (1) begin : g
    ifc u (.clk(|$unsigned(ck[s +: 2])));
  end
  assign o = g.u.sig[0];
endmodule
