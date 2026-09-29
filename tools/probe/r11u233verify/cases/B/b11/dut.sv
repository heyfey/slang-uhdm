// § sizeBitNetIsVar228 § parseViewSizeExprEval228 — a packed array of a typedef'd bit vector with two dimensions written (b2_t [3:0][2:0])
typedef bit [1:0] b2_t;
module sub (input b2_t [3:0][2:0] pp, output logic [7:0] o1, o2);
  wire [7:0] w1 = $size(pp);
  wire [7:0] w2 = $size(pp, 2);
  assign o1 = w1; assign o2 = w2;
endmodule
module dut (input b2_t [3:0][2:0] i, output logic [7:0] o1, o2);
  sub u (.pp(i), .o1(o1), .o2(o2));
endmodule
