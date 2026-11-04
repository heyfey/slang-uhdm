// § classTpDefaultTsAtUse180
package pkg;
  class base_c; endclass
  class holder #(type CB=base_c);
    function CB g();
      return null;
    endfunction
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
