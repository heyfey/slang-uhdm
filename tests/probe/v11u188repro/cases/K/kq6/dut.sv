// § classTpKeywordTsAtDefault188
class c #(type T = byte);
  T a;
  function void f(input T x, output T y);
    y = x;
  endfunction
  function void g(ref T z);
    z = a;
  endfunction
endclass
module top;
  c h;
  initial begin h = new(); end
endmodule
