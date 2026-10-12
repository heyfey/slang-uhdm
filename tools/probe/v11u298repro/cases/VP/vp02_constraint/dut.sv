// § castClsTpOwnDefaultObj298
// a cast in a constraint and in a property initializer
package p;
  class gen #(type U = logic [7:0]);
    rand int y;
    int z = U'(9);
    constraint c { y == U'(3); }
  endclass
endpackage
module top; endmodule
