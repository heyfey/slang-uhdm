module amod ();
  module innermod (output logic ra); assign ra = 1'b1; endmodule
endmodule
module bmod ();
  module innermod (input logic [3:0] ib); wire y = ib[1]; endmodule
endmodule
module dut (output logic [31:0] o);
  bmod u_b ();
  assign o = 32'd0;
endmodule
