// § castClsTpOwnDefaultObj298
// a signed logic vector default
package p;
  class gen #(type U = logic signed [7:0]);
    int y;
    function void f(); y = U'(-3); endfunction
  endclass
endpackage
module top; endmodule
