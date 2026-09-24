// LAW B: two outers nest an innermod; the file-scope program namesake
program innermod (); int f = 9; endprogram
module amod ();
  module innermod (); wire ra; endmodule
endmodule
module bmod ();
  module innermod (); wire [3:0] rb = 4'd3; endmodule
endmodule
module dut (output logic [31:0] o);
  amod u_a ();
  bmod u_b ();
  assign o = 32'd0;
endmodule
