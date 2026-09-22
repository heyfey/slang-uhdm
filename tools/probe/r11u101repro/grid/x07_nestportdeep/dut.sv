// LAW A x B4: a PORTED module nested two levels deep (golden: no def at depth 2)
module sub ();
  module mid ();
    module deep (output logic d);
      assign d = 1'b1;
    endmodule
    wire m;
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
