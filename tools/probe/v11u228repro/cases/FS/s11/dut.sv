// § parseViewSizeExprEval228 — a modport member and an interface array operand beside a local operand in the same child
interface bus;
  bit [3:0][1:0] x;
  modport m (input x);
endinterface
module sub (bus.m b, output logic [7:0] o1, o2);
  bit [2:0][1:0] loc;
  wire [7:0] w1 = $size(b.x);
  wire [7:0] w2 = $size(loc);
  assign o1 = w1; assign o2 = w2;
endmodule
module dut (output logic [7:0] o1, o2);
  bus bi ();
  sub u (.b(bi), .o1(o1), .o2(o2));
endmodule
