// § genNdaSelRhsSharesNet303
interface ifc (input logic [7:0] a);
  for (genvar i = 0; i < 2; ++i) begin : g
    wire [3:0] w = a[i*4 +: 4];
    wire x = a[0] & a[1];
  end
endinterface
module top (input logic [7:0] a, output logic o);
  ifc u (.a(a));
  assign o = a[0];
endmodule
