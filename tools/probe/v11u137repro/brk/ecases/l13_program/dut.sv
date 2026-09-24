// § elabCloneFullNameUnstored137
program prg(input logic a);
  initial begin : p
    logic q;
    q = a;
  end
endprogram
module top(input logic x);
  prg p(.a(x));
endmodule
