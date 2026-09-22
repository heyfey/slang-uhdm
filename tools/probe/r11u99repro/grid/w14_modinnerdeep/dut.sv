// a nested module inside a nested module
module sub ();
  module mid ();
    module deep ();
      wire [31:0] r = 32'd3;
    endmodule
  endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
