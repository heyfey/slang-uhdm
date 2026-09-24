// LAW A: sub and the file-scope instantiation both sit inside mid, one level below the top
module innermod (); wire [31:0] f = 32'd9; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module mid (); sub u_s (); innermod u_f (); endmodule
module dut (output logic [31:0] o);
  mid u_m ();
  assign o = 32'd0;
endmodule
