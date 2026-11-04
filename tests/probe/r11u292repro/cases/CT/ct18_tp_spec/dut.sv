// § castTypeParamDefaultLoc292
package p;
  class gen #(type T = int);
    int y;
    function void x2(); y = T'(4); endfunction
  endclass
  class user;
    gen #(byte) g = new();
    gen #() h = new();
  endclass
endpackage
