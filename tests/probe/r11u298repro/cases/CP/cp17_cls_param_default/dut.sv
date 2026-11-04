// § castClsTpOwnDefaultObj298
// a parameterized class default
package p;
  class base #(int N = 2); int a; endclass
  class gen #(type C = base #(3));
    C h;
    function void f(); h = C'(h); endfunction
  endclass
endpackage
module top; endmodule
