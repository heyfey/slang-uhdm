// § castClsTpNestedClsPlaceholder298v
// a cast in a nested class to the enclosing class's vector type parameter
package p;
  class gen #(type U = logic [7:0]);
    class inner;
      int y;
      function void f(); y = U'(3); endfunction
    endclass
  endclass
endpackage
module top; endmodule
