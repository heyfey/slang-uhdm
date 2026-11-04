// § ifaceSigConnNamedByChildPort155
interface myif (input logic clk);
  logic sig;
  modport s (input clk, output sig);
  modport m (input clk, input sig);
endinterface
module child (input logic clk, output logic q); always_ff @(posedge clk) q <= ~q; endmodule
module prod (myif.s a, output logic q); child c (.clk(a.clk), .q(q)); assign a.sig = q; endmodule
module cons (myif.m b, output logic q); child k (.clk(b.clk), .q(q)); endmodule
module dut (input logic clk, output logic q1, q2);
  myif mif (.clk(clk));
  prod p (.a(mif), .q(q1));
  cons n (.b(mif), .q(q2));
endmodule
