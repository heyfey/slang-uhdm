// § clsTfOpFoldTsLate423 (control: a class in a package, § pkgImportTfOpFoldTs159's own cell)
package p;
  typedef bit [27:0] f_t;
  parameter f_t A = (1<<4);
endpackage
package q;
  import p::*;
  class C;
    function bit f(f_t x);
      return x == A;
    endfunction
  endclass
endpackage
module top; q::C c; endmodule
