// § ndaSizeFoldReach219 — control: the same queries as continuous assignments and in a variable initializer, not net-declaration initializers
module dut (output logic [7:0] o1, o2, o3);
  logic [1:0] m [2][3];
  logic [7:0] vi = $size(m, 2);
  assign o1 = $size(m);
  assign o2 = $size(m, 2);
  assign o3 = vi;
endmodule
