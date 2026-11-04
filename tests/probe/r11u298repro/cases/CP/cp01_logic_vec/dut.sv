// § castClsTpOwnDefaultObj298
// a cast to a class type parameter defaulting to a logic vector
package p;
  class gen #(type U = logic [7:0]);
    int y;
    function void f(); y = U'(3); endfunction
  endclass
endpackage
module top; endmodule
