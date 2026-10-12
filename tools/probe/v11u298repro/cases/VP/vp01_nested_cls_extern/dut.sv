// § castClsTpOutOfBodyPlaceholder298
// a nested class's extern method defined inside the outer class body
package p;
  class outer;
    class gen #(type U = logic [7:0]);
      int y;
      extern function void f();
    endclass
    function void gen::f(); y = U'(3); endfunction
  endclass
endpackage
module top; endmodule
