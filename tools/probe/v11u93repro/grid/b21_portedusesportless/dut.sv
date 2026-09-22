module sub ();
  module pl (); wire [3:0] pw = 4'd1; endmodule
  module innermod (output logic r);
    pl u_p ();
    assign r = 1'b1;
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
