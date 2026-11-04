// § castClsTpOwnDefaultObj298
// a two-dimensional packed default
package p;
  class gen #(type U = logic [1:0][3:0]);
    int y;
    function void f(); y = U'(7); endfunction
  endclass
endpackage
module top; endmodule
