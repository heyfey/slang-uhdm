// § progLastInstSrcOrder283v
program prg (input logic [3:0] a); int f; initial f = a; endprogram
module dut (output logic [31:0] o);
  logic [3:0] x, y, z;
  prg u_p (.a(x));
  if (1) begin : g
    prg u_q (.a(y));
  end
  prg u_r (.a(z));
  assign o = 32'd0;
endmodule
