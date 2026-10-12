// § castClsTpOutOfBodyPlaceholder298
// an extern method body casting to an int and a real type parameter
package p;
  class gen #(type T = int, type R = real);
    int y; real z;
    extern function void f();
  endclass
  function void gen::f(); y = T'(3); z = R'(2); endfunction
endpackage
module top; endmodule
