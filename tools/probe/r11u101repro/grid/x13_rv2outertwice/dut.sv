// CONTROL: ONE outer instantiated TWICE (two bodies, one definition name)
module sub ();
  module innermod ();
    wire [31:0] r = 32'd2;
  endmodule
  module portmod (output logic p);
    assign p = 1'b0;
  endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s1 ();
  sub u_s2 ();
  assign o = 32'd0;
endmodule
