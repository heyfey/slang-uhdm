// § castClsTpOwnDefaultObj298
// a reg vector default and a logic default with two dimensions written by a typedef-free form
package p;
  class gen #(type U = reg [3:0], type V = bit);
    int y;
    function void f(); y = U'(3); y = V'(1); endfunction
  endclass
endpackage
module top; endmodule
