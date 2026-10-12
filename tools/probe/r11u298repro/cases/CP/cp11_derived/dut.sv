// § castClsTpOwnDefaultObj298
// a derived class passing its vector type parameter to the base
package p;
  class base #(type T = logic [3:0]);
    int y;
    function void f(); y = T'(5); endfunction
  endclass
  class der #(type T = logic [9:0]) extends base #(T);
    function void g(); y = T'(6); endfunction
  endclass
endpackage
module top; endmodule
