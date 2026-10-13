// § genIfaceParentAtBirth313
interface ifc (input logic clk, input logic [3:0] d);
  logic [7:0] sig;
  assign sig[3:0] = d;
  assign sig[7:4] = {4{clk}};
endinterface
module top (input logic a, input logic [3:0] d, output logic o);
  if (1) begin : g
    ifc u (.clk(a), .d(d[3:0]));
    assign o = u.sig[5];
  end
endmodule
