// § classTpDefaultTsAtUse180
package pkg;
  class base_c; endclass
  class holder #(type CB=base_c);
    function void f();
      CB cb;
      CB q[$];
      cb = null;
    endfunction
    CB m;
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
