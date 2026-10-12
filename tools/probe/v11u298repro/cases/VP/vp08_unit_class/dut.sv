// § castClsTpOwnDefaultObj298
// a class at compilation-unit scope with a vector default, and an extern method
class gen #(type U = logic [7:0]);
  int y;
  function void f(); y = U'(3); endfunction
  extern function void g();
endclass
function void gen::g(); y = U'(5); endfunction
module top; endmodule
