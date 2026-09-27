// § classTpDefaultTsAtUse180
package pkg;
  class base_c; endclass
  class my_c extends base_c; endclass
  class holder #(type CB=base_c);
    function void f();
      CB cb;
      cb = null;
    endfunction
  endclass
endpackage
module top();
pkg::holder #(pkg::my_c) c1;
endmodule
