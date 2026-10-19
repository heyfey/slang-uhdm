// § modKwlessTypeParamDropped412
module sub #(parameter type T = real, type U = int, parameter W = 2);
  T a;
  U b;
endmodule
module top;
  sub u();
endmodule
