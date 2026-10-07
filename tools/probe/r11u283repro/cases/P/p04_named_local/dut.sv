// § progDefKeepsLastInstProcs283
program prg (input logic [3:0] a);
  int f;
  initial begin : blk
    int t;
    t = a;
    f = t + 1;
  end
endprogram
module dut (output logic [31:0] o);
  logic [3:0] x, y;
  prg u_1 (.a(x));
  prg u_2 (.a(y));
  assign o = 32'd0;
endmodule
