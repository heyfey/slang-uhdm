// r10uvm122 arm f — the IMPORT-CLONE fence.  `p122f_home` holds the law's own
// shape; the three importers re-emit a CLONE of it, and golden's clone binds
// the HOME package's declaration, never the clone's own select.
package p122f_home;
  function int f122f (int unsigned s);
    bit [31:0] hv;
    hv = 1;
    if (s) begin
      hv ^= 3;                 // cell f_home
      hv[0] = 1;
    end
    return hv;
  endfunction
  function int g122f (int unsigned s);
    int gv [0:3];
    if (s) begin
      gv = '{default:0};       // cell f_arr
      gv[0] = 1;
    end
    return gv[1];
  endfunction
endpackage

// f1 — a WILDCARD import
package p122f_wild;
  import p122f_home::*;
  function int use1 (int unsigned s); return f122f(s) + g122f(s); endfunction
endpackage

// f2 — an EXPLICIT single-name import
package p122f_expl;
  import p122f_home::f122f;
  function int use2 (int unsigned s); return f122f(s); endfunction
endpackage

// f3 — a MODULE that wildcard-imports the package
module m122f;
  import p122f_home::*;
  int r;
  initial r = f122f(1);
endmodule
