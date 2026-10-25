// § modArrConcatInitElemSize430
module sub;
  logic [3:0] tab[2] = { 1, 2 };
endmodule
module top;
  sub u1();
  sub u2();
endmodule
