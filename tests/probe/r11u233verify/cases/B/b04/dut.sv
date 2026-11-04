// § sizeBitNetIsVar228 § parseViewSizeExprEval228 — an unpacked array of bit on a port (the law does not apply: control)
module sub (input bit [3:0] pp [2], output logic [7:0] o1, o2);
  wire [7:0] w1 = $size(pp);
  wire [7:0] w2 = $size(pp, 2);
  assign o1 = w1; assign o2 = w2;
endmodule
module dut (input bit [3:0] i [2], output logic [7:0] o1, o2);
  sub u (.pp(i), .o1(o1), .o2(o2));
endmodule
