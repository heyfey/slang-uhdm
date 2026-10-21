// § clsMethodLocalForeignPkgSpec428
package p;
  class box #(type T = int);
  endclass
endpackage
class C;
  typedef int my_t;
  function void f(p::box #(int) a);
    p::box #(my_t) b;
  endfunction
endclass
module top;
  C c;
endmodule
