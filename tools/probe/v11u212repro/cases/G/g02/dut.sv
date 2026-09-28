// § pkgEnumAliasListingParent212 — verifier: a package alias of an enum typedef, the alias typing a package function return
package p;
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef e_t f_t;
  function automatic f_t nxt(input logic [1:0] x);
    return f_t'(x + 1);
  endfunction
endpackage
module dut(input logic [1:0] i, output logic o);
  assign o = p::nxt(i) == p::B;
endmodule
