// § nestedDefSecondBodyReadsRep307
module outer (input logic clk, input logic d, output logic q);
  module inner (input logic clk, input logic d, output logic q);
    always_ff @(posedge clk) q <= d;
  endmodule
  inner u_i (.clk(clk), .d(d), .q(q));
endmodule
module dut (input logic clk, input logic [1:0] d, output logic [1:0] q);
  outer u_o (.clk(clk), .d(d[0]), .q(q[0]));
  outer u_p (.clk(clk), .d(d[1]), .q(q[1]));
endmodule
