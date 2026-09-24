// r11u93 pa15 -- THE CONTROL: the same generate block in a MODULE home.
module sub ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      wire [31:0] w_gen = 32'd12;
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
