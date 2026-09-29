// § sizeBitNetIsVar228 § parseViewSizeExprEval228 — a packed array of a typedef'd logic vector (control: not a bit net)
typedef logic [1:0] l2_t;
module sub (input l2_t [3:0] pp, output logic [7:0] o1, o2);
  wire [7:0] w1 = $size(pp);
  wire [7:0] w2 = $size(pp, 2);
  assign o1 = w1; assign o2 = w2;
endmodule
module dut (input l2_t [3:0] i, output logic [7:0] o1, o2);
  sub u (.pp(i), .o1(o1), .o2(o2));
endmodule
