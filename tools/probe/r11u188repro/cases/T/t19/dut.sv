// § classTpKeywordTsAtDefault188
typedef int myint;
class c #(type T = myint);
  function void m();
    T t;
  endfunction
endclass
module top; endmodule
