// § classTpFormalMovesTs180
package pkg;
  class base_c; endclass
  class holder #(type CB=base_c);
    CB m;
    extern function void f(CB x);
  endclass
  function void holder::f(CB x);
    m = x;
  endfunction
endpackage
module top();
pkg::holder c1;
endmodule
