// § castClsTpOwnDefaultObj298
// two casts to the same vector type parameter and a variable of that type
package p;
  class gen #(type U = logic [7:0]);
    U v;
    int y;
    function void f(); y = U'(3); v = U'(y + 1); endfunction
  endclass
endpackage
module top; endmodule
