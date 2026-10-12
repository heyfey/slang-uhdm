// § castClsTpOutOfBodyPlaceholder298
// a class in a module with an extern method casting to the vector type parameter
module top;
  class gen #(type U = logic [7:0]);
    int y;
    extern function void f();
  endclass
  function void gen::f(); y = U'(3); endfunction
endmodule
