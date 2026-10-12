// § castClsTpOwnDefaultObj298
// a class declared in a module with a vector type parameter default
module top;
  class gen #(type U = logic [7:0]);
    int y;
    function void f(); y = U'(3); endfunction
  endclass
  gen g;
  initial begin g = new; g.f(); end
endmodule
