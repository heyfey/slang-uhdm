// § classTpFormalMovesTs180 (verifier: an extern prototype last in the body; its definition outside, and an inline method before it)
package pkg;
  class base_c; endclass
  class holder #(type CB=base_c);
    CB m;
    function void a(CB y); m = y; endfunction
    extern function void f(CB x);
  endclass
  function void holder::f(CB x);
    CB tmp;
    tmp = x;
    m = tmp;
  endfunction
endpackage
module top();
pkg::holder c1;
endmodule
