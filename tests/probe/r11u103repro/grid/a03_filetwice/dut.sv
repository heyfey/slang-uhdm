// LAW A: the file-scope innermod is instantiated in dut AND in a later module mid
module innermod (output logic q); assign q = 1'b1; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module mid (output logic m); innermod u_m (.q(m)); endmodule
module dut (output logic [31:0] o);
  logic p, r;
  sub u_s ();
  innermod u_f (.q(p));
  mid u_d (.m(r));
  assign o = 32'd0;
endmodule
