// v11u93 x28 -- body class, GEN class, body class: what order does golden list?
program prg ();
  class Ca; int a; endclass
  generate
    if (1) begin : g
      class Cb; int b; endclass
    end
  endgenerate
  class Cc; int c; endclass
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
