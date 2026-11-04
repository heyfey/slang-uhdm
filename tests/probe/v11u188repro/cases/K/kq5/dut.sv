// § classTpKeywordTsAtDefault188
class c #(type T = int, type T2 = T);
  T2 a;
  T b;
  function void f(T2 x); a = x; endfunction
  function void g(T y); b = y; endfunction
endclass
module top; endmodule
