// § ndaUnsizedRhsFreshLhs438
module sub(input [3:0] i, output y);
  struct packed { logic [3:0] f; logic [3:0] g; } s;
  assign s = {i, i};
  wire w = s.f['h1];
  assign y = w;
endmodule
module top(input [3:0] i, output y);
  sub u(.i(i), .y(y));
endmodule
