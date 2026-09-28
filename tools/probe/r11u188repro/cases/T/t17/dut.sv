// § classTpKeywordTsAtDefault188
class c #(type T = int);
  function void m();
    T t;
  endfunction
endclass
module top;
  c #(byte) h;
  c hd;
endmodule
