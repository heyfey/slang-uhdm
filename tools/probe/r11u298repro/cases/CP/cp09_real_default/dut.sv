// § castClsTpOwnDefaultObj298
// a real default (the law abstains)
package p;
  class gen #(type R = real);
    real z;
    function void f(); z = R'(3); endfunction
  endclass
endpackage
module top; endmodule
