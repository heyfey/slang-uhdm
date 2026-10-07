// § progDefKeepsLastInstProcs283
program prg (input logic [3:0] a);
  int f, g;
  initial begin
    fork
      begin : b1 f = a; end
      begin : b2 g = a + 1; end
    join
  end
endprogram
module dut (output logic [31:0] o);
  logic [3:0] x, y;
  prg u_p (.a(x));
  prg u_q (.a(y));
  assign o = 32'd0;
endmodule
