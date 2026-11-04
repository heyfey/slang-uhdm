// § castTypeParamDefaultLoc292
package p;
  class gen #(type T = shortint);
    int y;
    function void x2(); y = T'(4); endfunction
  endclass
endpackage
module top;
  p::gen #(longint) g1 = new();
  p::gen #(byte) g2;
  p::gen g3;
  initial g1.x2();
endmodule
