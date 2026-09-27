// § classTpDefaultTsAtUse180
package other;
  class base_c; endclass
endpackage
package pkg;
  class holder #(type CB=other::base_c);
    function void f();
      CB cb;
      cb = null;
    endfunction
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
