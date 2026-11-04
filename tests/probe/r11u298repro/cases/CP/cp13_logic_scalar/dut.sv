// § castClsTpOwnDefaultObj298
// a scalar logic default and a parameter-sized vector default
package p;
  class gen #(int W = 4, type U = logic, type V = logic [W-1:0]);
    int y;
    function void f(); y = U'(1); y = V'(2); endfunction
  endclass
endpackage
module top; endmodule
