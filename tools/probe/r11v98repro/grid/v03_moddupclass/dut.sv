// v03 -- the SAME class name in the module body and in a generate block.
module sub ();
  class C; int body_x; endclass
  generate
    if (1) begin : g
      class C; int gen_x; endclass
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
