// § castTypeParamDefaultLoc292
package p;
  class gen #(type T = int);
    int y;
    function void x2();
      int i = T'(3);
      y = T'(4);
    endfunction
  endclass
endpackage
