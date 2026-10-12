// § castTypeParamDefaultLoc292
package p;
  typedef logic [3:0] n_t;
  class gen #(type T = byte, type U = logic [7:0], type V = n_t);
    int y;
    function void x2();
      y = T'(3);
      y = U'(3);
      y = V'(3);
    endfunction
  endclass
endpackage
