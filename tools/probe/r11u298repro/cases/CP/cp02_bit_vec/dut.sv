// § castClsTpOwnDefaultObj298
// a cast to a class type parameter defaulting to a bit vector
package p;
  class gen #(type U = bit [3:0]);
    int y;
    function void f(); y = U'(2); endfunction
  endclass
endpackage
module top; endmodule
