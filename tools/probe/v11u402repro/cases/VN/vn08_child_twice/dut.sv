// § netKindTypeAll402
module child(input tri0 a, output tri1 b);
  trior z;
  assign z = a;
  assign b = z;
endmodule
module top(input x, output y1, y2);
  child c1(.a(x), .b(y1));
  child c2(.a(x), .b(y2));
endmodule
