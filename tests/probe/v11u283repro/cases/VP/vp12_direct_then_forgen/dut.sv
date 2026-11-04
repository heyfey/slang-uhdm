// § progLastInstSrcOrder283v
program prg (input logic [3:0] a); int f; initial f = a; endprogram
module dut (output logic [31:0] o);
  logic [3:0] x, y;
  prg u_p (.a(x));
  for (genvar i = 0; i < 2; i++) begin : g
    prg u_q (.a(y));
  end
  assign o = 32'd0;
endmodule
