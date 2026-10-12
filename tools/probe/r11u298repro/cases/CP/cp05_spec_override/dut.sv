// § castClsTpOwnDefaultObj298
// a specialization overriding the vector default, used from a module
package p;
  class gen #(type U = logic [7:0]);
    int y;
    function void f(); y = U'(3); endfunction
  endclass
endpackage
module top;
  p::gen #(logic [3:0]) g;
  initial begin g = new; g.f(); end
endmodule
