// § castClsTpOwnDefaultObj298
// a typedef default (the class listing's own object is the sister's ground)
package p;
  typedef logic [3:0] n_t;
  class gen #(type V = n_t);
    int y;
    function void f(); y = V'(3); endfunction
  endclass
endpackage
module top; endmodule
