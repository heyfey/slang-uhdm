// § castTypeParamDefaultKind292
package p;
  class gen #(type T = shortint, type U = longint, type V = integer, type W = int unsigned);
    longint y;
    function void x2();
      y = T'(3);
      y = U'(3);
      y = V'(3);
      y = W'(3);
    endfunction
  endclass
endpackage
