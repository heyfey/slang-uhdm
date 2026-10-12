// § castTypeParamDefaultLoc292
package p;
  class gen #(type T = byte);
    int y;
    function void x2(); y = T'(4); endfunction
  endclass
endpackage
