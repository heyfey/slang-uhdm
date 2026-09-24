// v17 -- a PROGRAM body class Zbody and a program gen-block class Agen.
program prg ();
  class Zbody; int z; endclass
  generate
    if (1) begin : g
      class Agen; int a; endclass
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
