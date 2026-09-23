// LAW A x library: the file-scope innermod lives in a -v library and dut instantiates it
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  innermod u_f ();
  assign o = 32'd0;
endmodule
