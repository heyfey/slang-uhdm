// § castClsTpOwnDefaultObj298
// a cast of a this. path and a static function call result, two type parameters
package p;
  class gen #(type U = bit [5:0], type V = logic signed [3:0]);
    int y;
    U u;
    static function int s(); return 2; endfunction
    function void f(); u = U'(this.y); y = V'(s()); endfunction
  endclass
endpackage
module top; endmodule
