// § castClsTpOwnDefaultObj298
// a class default (the law abstains)
package p;
  class base; int a; endclass
  class gen #(type C = base);
    C h;
    function void f(); h = C'(h); endfunction
  endclass
endpackage
module top; endmodule
