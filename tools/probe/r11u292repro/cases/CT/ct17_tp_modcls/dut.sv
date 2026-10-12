// § castTypeParamDefaultLoc292
module top;
  class gen #(type T = int);
    int y;
    function void x2(); y = T'(4) + 1; endfunction
  endclass
  gen #(byte) o = new();
endmodule
