// § castClsTpOwnDefaultObj298
// a class in a module with an in-body cast, used by an initial block
module top;
  class gen #(type U = logic [7:0]);
    int y;
    function void f(); y = U'(3); endfunction
  endclass
  gen g;
  initial begin g = new; g.f(); end
endmodule
