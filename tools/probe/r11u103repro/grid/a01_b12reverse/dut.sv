// CONTROL (r11u101 shadow road): dut instantiates the file-scope innermod BEFORE sub
module innermod (); wire [31:0] f = 32'd9; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  innermod u_f ();
  sub u_s ();
  assign o = 32'd0;
endmodule
