// LAW A: two nested names, two late file-scope top namesakes
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
  module inner2 (); wire [3:0] m = 4'd2; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b); assign b = a; endmodule
module inner2 (output logic z); assign z = 1'b1; endmodule
