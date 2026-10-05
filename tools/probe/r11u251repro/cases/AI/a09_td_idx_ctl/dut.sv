// § clsTdAssocIdxKwLoc251
package p;
typedef bit [3:0] k_t;
class c #(type T=int);
  typedef T tab_t[k_t];
  function bit check(const ref tab_t strtab); return 0; endfunction
endclass
endpackage
module top; endmodule
