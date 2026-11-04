// § castClsTpOwnDefaultObj298
// a cast of a this. path and a cast in a select bound of a this. path
package p;
  class gen #(type U = logic [7:0]);
    logic [15:0] v;
    int y;
    function void f(); y = U'(this.v); y = this.v[U'(4):0]; endfunction
  endclass
endpackage
module top; endmodule
