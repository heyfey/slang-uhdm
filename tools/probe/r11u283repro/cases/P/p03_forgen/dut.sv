// § progDefKeepsLastInstProcs283
program prg (input logic [3:0] a); int f; initial f = a; endprogram
module dut (output logic [31:0] o);
  logic [3:0] x [2];
  for (genvar i = 0; i < 2; i++) begin : g
    prg u_p (.a(x[i]));
  end
  assign o = 32'd0;
endmodule
