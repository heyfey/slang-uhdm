// LAW A: the outer is NEVER instantiated, so it is a second top beside dut; nested ported module
module sub ();
  module innermod (input logic i);
    wire w = i;
  endmodule
endmodule
module dut (output logic [31:0] o);
  assign o = 32'd0;
endmodule
