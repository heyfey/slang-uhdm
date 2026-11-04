// § progLastInstSrcOrder283v
program prg (input logic [3:0] a); int f; initial f = a; endprogram
module sub (input logic [3:0] a); prg u_s (.a(a)); endmodule
module dut (output logic [31:0] o);
  logic [3:0] x, y;
  sub u_sub (.a(x));
  prg u_q (.a(y));
  assign o = 32'd0;
endmodule
