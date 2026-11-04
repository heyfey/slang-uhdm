// § genNdaSelRhsSharesNet303
module sub (input logic [7:0] a, output logic o);
  for (genvar i = 0; i < 2; ++i) begin : g
    wire [3:0] w = a[i*4 +: 4];
    wire x = ~a[i];
  end
  assign o = a[0];
endmodule
module top (input logic [7:0] a, output logic o1, o2);
  sub u1 (.a(a), .o(o1));
  sub u2 (.a(a), .o(o2));
endmodule
