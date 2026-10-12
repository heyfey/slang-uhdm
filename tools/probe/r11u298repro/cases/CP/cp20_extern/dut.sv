// § castClsTpOutOfBodyPlaceholder298
// an extern method body (out of the class) casting to the vector type parameter
package p;
  class gen #(type U = logic [7:0]);
    int y;
    extern function void f();
  endclass
  function void gen::f(); y = U'(3); endfunction
endpackage
module top; endmodule
