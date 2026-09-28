// § ndaSysCallNetTs212 — a signed net declared with an initializer that is a signing cast (r11u199 N6's second net)
module dut (input logic [9:0] i, output logic [6:0] o);
  wire signed [6:0] v = signed'(i[6:0]);
  assign o = v;
endmodule
