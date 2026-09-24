// r11u98 h7 -- a class in a MODULE's for-generate, bound 2: how many copies?
module sub ();
  generate
    for (genvar i = 0; i < 2; i++) begin : gl
      class Cloop; int x; endclass
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
