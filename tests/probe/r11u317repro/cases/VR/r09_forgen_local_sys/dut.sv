// § genSysArgInnerUnbound317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, input logic [1:0] k, input logic [2:0] s, input logic [1:0][1:0] m, input logic a, output logic o);
  for (genvar i = 0; i < 2; i++) begin : g
    logic [1:0] l;
    assign l = k;
    ifc u (.clk($signed(ck[l[i]] & a)));
  end
  assign o = a;
endmodule
