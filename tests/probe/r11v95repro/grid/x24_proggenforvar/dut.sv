// v11u93 x24 -- the landed pa4_progfor shape: a two-iteration loop's NET.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    for (genvar i = 0; i < 2; i++) begin : g
      wire [31:0] w_loop = 32'd12;
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
