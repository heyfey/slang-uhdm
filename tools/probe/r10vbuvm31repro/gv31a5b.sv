// v31a5 — NAME/BIND adversary: pattern operands that are NAMES, scoped names,
// calls and system calls, at all three carriers.  The patch changes the PARENT
// passed to emitExpr for the class carrier; anything that binds through that
// parent chain shows up here.
package v31p5;
  parameter int PP = 4;
  function automatic int pf5(); return 7; endfunction
  int pd_p[]        = '{PP, PP + 1};
  int paa_p[string] = '{default: PP};
  int pd_c[]        = '{pf5(), 2};
  int pd_sb[]       = '{$bits(int), 1};
  int pd_sc[string] = '{default: v31p5::PP};
endpackage

module v31m5;
  import v31p5::*;
  localparam int LP = 5;
  function automatic int mf5(); return 8; endfunction
  int md_p[]        = '{LP, LP + 1};
  int maa_p[string] = '{default: LP};
  int md_c[]        = '{mf5(), 2};
  int md_sb[]       = '{$bits(int), 1};
  int md_sc[]       = '{v31p5::PP, 1};

  class v31c5;
    localparam int CP = 6;
    static function int cf5(); return 9; endfunction
    int cd_p[]        = '{CP, CP + 1};
    int caa_p[string] = '{default: CP};
    int cd_c[]        = '{cf5(), 2};
    int cd_sb[]       = '{$bits(int), 1};
    int cd_sc[]       = '{v31p5::PP, 1};
    int cd_lp[]       = '{LP, 1};
    int caa_sc[string]= '{default: v31p5::PP};
    int cq_p[$]       = '{CP, LP};
  endclass

  class v31c5b;
    int ob_d[];
    int ob_aa[string];
    extern function int m();
  endclass
  function int v31c5b::m(); return ob_d.size() + ob_aa.size(); endfunction

  v31c5 h5 = new();
  initial $display(h5.cd_p.size(), md_p.size(), v31p5::pd_p.size());
endmodule
