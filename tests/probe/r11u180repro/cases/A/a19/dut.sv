// § classTpDefaultTsAtUse180
package pkg;
  class base_c; endclass
  class holder #(type CB=base_c);
    typedef CB cb_t;
    CB m;
    function void f(cb_t x);
      m = x;
    endfunction
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
