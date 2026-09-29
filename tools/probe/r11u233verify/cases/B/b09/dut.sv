// § sizeBitNetIsVar228 § parseViewSizeExprEval228 — a typedef of a packed array of a typedef'd bit vector (typedef b2_t [3:0] b8_t)
typedef bit [1:0] b2_t;
typedef b2_t [3:0] b8_t;
module sub (input b8_t pp, output logic [7:0] o1, o2);
  wire [7:0] w1 = $size(pp);
  wire [7:0] w2 = $size(pp, 2);
  assign o1 = w1; assign o2 = w2;
endmodule
module dut (input b8_t i, output logic [7:0] o1, o2);
  sub u (.pp(i), .o1(o1), .o2(o2));
endmodule
