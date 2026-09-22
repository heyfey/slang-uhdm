// v11u93 x7 -- LAW B x the CLASS face.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    for (genvar i = 0; i < 0; i++) begin : g
      class Czero; int x; endclass
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
