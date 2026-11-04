// § pkgEnumAliasListingParent212 — a package alias of a struct typedef, used as a function formal (control: the struct side)
package p;
  typedef struct packed { logic [3:0] a; } s_t;
  typedef s_t f_t;
  function automatic int g(f_t v); return int'(v.a); endfunction
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
