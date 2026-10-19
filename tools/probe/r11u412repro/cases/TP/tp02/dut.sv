// § modKwlessTypeParamDropped412
module sub #(type T = real, type U = int, type V = shortreal);
  T a;
endmodule
module top #(type T = int, type R = real);
  sub #(.T(real)) u();
endmodule
