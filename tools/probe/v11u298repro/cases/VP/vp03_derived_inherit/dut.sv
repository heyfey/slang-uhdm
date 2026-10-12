// § castClsTpNestedClsPlaceholder298v
// a derived class casting to the base class's type parameter by name
package p;
  class base #(type U = logic [7:0]);
    int y;
  endclass
  class der extends base #(logic [3:0]);
    function void f(); y = U'(3); endfunction
  endclass
endpackage
module top; endmodule
