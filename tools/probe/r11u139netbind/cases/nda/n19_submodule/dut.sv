module mid(input p, input q, output y);
  wire w = p & q;
  assign y = w;
endmodule
module top(input i, input j, output y);
  mid m(.p(i), .q(j), .y(y));
endmodule
