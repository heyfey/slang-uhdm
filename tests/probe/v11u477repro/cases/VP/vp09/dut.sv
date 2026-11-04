// § parenCallWrittenArgs477
module sub #(parameter int K = 1) (input int a, output int z);
  function automatic int f(int x, int y = K); return x + y; endfunction
  assign z = (f(a));
endmodule
module top(input int a, output int z1, output int z2);
  sub u1(.a(a), .z(z1));
  sub #(.K(3)) u2(.a(a), .z(z2));
endmodule
