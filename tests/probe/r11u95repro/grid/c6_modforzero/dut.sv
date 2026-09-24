// r11u95 c6 -- THE CONTROL: a ZERO-iteration loop in a MODULE home.
module sub ();
  wire [31:0] w_plain = 32'd11;
  generate
    for (genvar i = 0; i < 0; i++) begin : g
      wire [31:0] w_loop = 32'd12;
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
