// § castClsTpOwnDefaultObj298
// a packed struct default and an enum default (the law must abstain)
package p;
  typedef enum logic [1:0] {A, B} e_t;
  class gen #(type U = struct packed { logic [3:0] a; }, type V = e_t);
    int y;
    function void f(); y = U'(3); y = V'(1); endfunction
  endclass
endpackage
module top; endmodule
