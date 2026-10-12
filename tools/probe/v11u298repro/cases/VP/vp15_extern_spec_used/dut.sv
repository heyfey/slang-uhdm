// § castClsTpOutOfBodyPlaceholder298
// an extern method casting to U with the class specialized and called from a module
package p;
  class gen #(type U = logic [7:0]);
    int y;
    extern function void f();
  endclass
  function void gen::f(); y = U'(3); endfunction
endpackage
module top;
  p::gen #(logic [3:0]) g;
  initial begin g = new; g.f(); end
endmodule
