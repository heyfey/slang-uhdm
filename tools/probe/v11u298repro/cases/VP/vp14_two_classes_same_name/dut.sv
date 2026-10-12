// § castClsTpOwnDefaultObj298
// two classes each with a type parameter U of different defaults, casts in both
package p;
  class a #(type U = logic [7:0]);
    int y;
    function void f(); y = U'(3); endfunction
  endclass
  class b #(type U = bit [3:0]);
    int y;
    function void f(); y = U'(4); endfunction
  endclass
endpackage
module top; endmodule
