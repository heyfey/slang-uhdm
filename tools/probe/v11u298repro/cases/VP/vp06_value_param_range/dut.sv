// § castClsTpOwnDefaultObj298
// a default ranged by a value parameter of the class, specialized from a module
package p;
  class gen #(int N = 4, type U = logic [N-1:0]);
    int y;
    function void f(); y = U'(3); endfunction
  endclass
endpackage
module top;
  p::gen #(8) g;
  initial begin g = new; g.f(); end
endmodule
