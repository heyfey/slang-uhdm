// § caPlainLhsUnsizedClone438
module sub(input [3:0] i, output y);
  struct packed { logic [3:0] f; logic [3:0] g; } s;
  assign s = {i, i};
  assign y = s.f['h1];
endmodule
module top(input [3:0] i, output y);
  sub u(.i(i), .y(y));
endmodule
