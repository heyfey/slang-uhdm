// § castTypeParamDefaultKind292
module top;
  class c #(type T = shortint, type U = longint);
    int y;
    function void f(); y = T'(5); y = U'(y); endfunction
  endclass
  c #() h;
  c #(int, byte) k;
endmodule
