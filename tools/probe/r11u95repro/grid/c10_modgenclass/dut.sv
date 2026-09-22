// r11u95 c10 -- THE CONTROL: a class in a MODULE's generate block.
module sub ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      class C; int x; endclass
      wire [31:0] w_gen = 32'd12;
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
