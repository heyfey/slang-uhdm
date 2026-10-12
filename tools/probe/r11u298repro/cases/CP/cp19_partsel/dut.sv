// § castClsTpOwnDefaultObj298
// constant slot: a cast in a part-select bound inside a class method
package p;
  class gen #(type U = logic [3:0]);
    logic [15:0] v;
    int y;
    function void f(); y = v[U'(5):0]; endfunction
  endclass
endpackage
module top; endmodule
