// § pkgArrTdElemClone209 — r11u217 h04: the package array typedef used as a CLASS property and in a package function, and by a module through a wildcard import
package q;
  typedef struct packed { logic y; logic [2:0] z; } s_t;
  typedef s_t [3:0] v_t;
  function automatic logic pick(v_t x); return x[1].y; endfunction
endpackage
package r;
  import q::*;
  class k;
    v_t m;
  endclass
endpackage
module top import q::*; (output logic o);
  v_t w;
  assign w = '0;
  assign o = pick(w) | w[3].z[0];
endmodule
