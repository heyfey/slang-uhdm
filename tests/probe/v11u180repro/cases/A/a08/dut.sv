// § classTpDefaultTsAtUse180 (verifier: the parameter used in a specialization held by a module)
package pkg;
  class base_c; endclass
  class der_c extends base_c; endclass
  class holder #(type CB=base_c);
    CB m;
    function CB get(); return m; endfunction
  endclass
endpackage
module top();
pkg::holder #(pkg::der_c) c1;
pkg::holder c2;
endmodule
