// § castClsTpOwnDefaultObj298
// a cast in a static function and in a constructor
package p;
  class gen #(type U = logic [7:0]);
    static int s;
    int y;
    function new(); y = U'(1); endfunction
    static function int g(); return U'(9); endfunction
  endclass
endpackage
module top; endmodule
