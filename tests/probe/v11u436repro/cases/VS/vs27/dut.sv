// § clsSpecKwlessFirstOrder436v
class C #(parameter p = 2, int q = 1, type T = int, parameter type U = int);
endclass
module top;
C#(1, 2, real, bit) v;
endmodule
