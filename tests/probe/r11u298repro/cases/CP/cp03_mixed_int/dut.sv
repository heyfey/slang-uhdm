// § castClsTpOwnDefaultObj298
// an int default beside a vector default (the integer keyword keeps pass 292's copy)
package p;
  class gen #(type T = int, type U = logic [5:0]);
    int y;
    function void f(); y = T'(1); y = U'(2); endfunction
  endclass
endpackage
module top; endmodule
