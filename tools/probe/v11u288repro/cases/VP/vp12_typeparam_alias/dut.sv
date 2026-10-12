// § parenCastReadsCastSyntax288 — a parenthesized cast to a typedef of a type parameter and to a class type parameter
class pc #(type T = int);
  function T cv(int v); return (T'(v)); endfunction
endclass
module m #(parameter type T = logic [3:0])(input logic [7:0] x, output logic [7:0] o);
  typedef T tt;
  assign o = (tt'(x)) + 1;
endmodule
module top(input logic [7:0] x, output logic [7:0] o); m u(.*); pc #(byte) p; endmodule
