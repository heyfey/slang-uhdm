// § sizeBitNetIsVar228 § parseViewSizeExprEval228 — a non-ANSI bit net port and an input var bit port (a variable: control)
module sub (pp, pv, o1, o2);
  input bit [3:0][1:0] pp;
  input var bit [3:0][1:0] pv;
  output logic [7:0] o1, o2;
  wire [7:0] w1 = $size(pp);
  wire [7:0] w2 = $size(pv);
  assign o1 = w1; assign o2 = w2;
endmodule
module dut (input bit [3:0][1:0] i, output logic [7:0] o1, o2);
  sub u (.pp(i), .pv(i), .o1(o1), .o2(o2));
endmodule
