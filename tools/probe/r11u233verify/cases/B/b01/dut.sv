// § sizeBitNetIsVar228 § parseViewSizeExprEval228 — an ANSI bit net port in both argument forms
module sub (input bit [3:0][1:0] pp, output logic [7:0] o1, o2);
  wire [7:0] w1 = $size(pp, 1);
  wire [7:0] w2 = $size(pp, 2);
  assign o1 = w1; assign o2 = w2;
endmodule
module dut (input bit [3:0][1:0] i, output logic [7:0] o1, o2);
  sub u (.pp(i), .o1(o1), .o2(o2));
endmodule
