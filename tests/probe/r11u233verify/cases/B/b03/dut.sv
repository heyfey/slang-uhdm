// § sizeBitNetIsVar228 § parseViewSizeExprEval228 — a one-dimensional signed bit net port and a one-bit bit net port
module sub (input bit signed [7:0] ps, input bit [0:0] sc, output logic [7:0] o1, o2);
  wire [7:0] w1 = $size(ps);
  wire [7:0] w2 = $size(sc);
  assign o1 = w1; assign o2 = w2;
endmodule
module dut (input bit signed [7:0] i, input bit [0:0] j, output logic [7:0] o1, o2);
  sub u (.ps(i), .sc(j), .o1(o1), .o2(o2));
endmodule
