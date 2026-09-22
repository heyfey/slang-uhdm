// r11u95 a11 -- LOOP BOUND 1: one iteration, a net and an initial.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    for (genvar i = 0; i < 1; i++) begin : g
      wire [31:0] w_loop = 32'd12;
      initial begin
        $display("loop");
      end
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
