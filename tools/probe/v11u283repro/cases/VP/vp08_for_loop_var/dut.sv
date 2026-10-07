// § progDefKeepsLastInstProcs283
program prg (input logic [3:0] a);
  int f;
  initial begin
    for (int i = 0; i < 2; i++) f += a;
  end
endprogram
module dut (output logic [31:0] o);
  logic [3:0] x, y;
  prg u_p (.a(x));
  prg u_q (.a(y));
  assign o = 32'd0;
endmodule
