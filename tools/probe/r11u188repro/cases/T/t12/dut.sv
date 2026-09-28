// § classTpKeywordTsAtDefault188
class c #(type T = int);
  function void f1(T x);
  endfunction
  function void m();
    T t;
  endfunction
  function void f2(input T y);
  endfunction
endclass
module top; endmodule
