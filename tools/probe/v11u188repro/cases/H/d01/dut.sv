// § classTpKeywordTsAtDefault188
class base #(type T = int);
  T x;
  function void f(T a); x = a; endfunction
endclass
class der extends base #(byte);
  function void g(); f(1); endfunction
endclass
module m;
  der d;
  initial d = new();
endmodule
