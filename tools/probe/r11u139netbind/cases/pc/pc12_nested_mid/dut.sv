module sub(input a, input b, output y); assign y = a ^ b; endmodule
module mid(input p, input q, output y);
  sub u(.a(p & q), .b(q | p), .y(y));
endmodule
module top(input i, input j, output y);
  mid m(.p(i), .q(j), .y(y));
endmodule
