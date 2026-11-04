// § castClsTpNestedClsPlaceholder298v
// a cast in a nested class to the enclosing class's int type parameter, and the nested class's own vector parameter
package p;
  class gen #(type T = int);
    class inner #(type V = logic [3:0]);
      int y;
      function void f(); y = T'(3); y = V'(2); endfunction
    endclass
  endclass
endpackage
module top; endmodule
