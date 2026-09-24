// § implicitNetMintNoFile131
module sub (input logic a);
endmodule
module tb;
  logic a;
  sub u(.a(a));
  initial $dumpvars(1, u);
endmodule
