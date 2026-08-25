// r10uvm145 arm C — THE HOMES.  MEASUREMENT ONLY.
// package free subroutine / in-body class method / OUT-OF-BODY class method /
// module task+function / program / interface / CLASS CONSTRUCTOR (§ 71 and
// § 142v must stay) / QUALIFIER+LIFETIME stub (§ 141 must stay), each written
// both paren-less (TF-ITEM) and with a port paren (BLOCK-ITEM).
// A class method may not call $display under Surelog's `-nobuiltin`, so the
// class cells write a member instead — the statement AFTER the declarations is
// what the threshold needs, not what it prints.
package pc145;

  class Holder145;
    int hv;
    int acc;
    // ---- IN-BODY class methods -----------------------------------------
    function void inbNoParen145;
      int ci = 17;
      ci = ci + hv;
      acc = ci;
    endfunction
    function void inbParen145();
      int ci = 17;
      ci = ci + hv;
      acc = ci;
    endfunction
    // ---- CONSTRUCTORS: § ctorBodyLocalsNotOnFunc71 must NOT move --------
    function new();
      int cn = 23;
      hv = cn;
      acc = cn;
    endfunction
    // ---- out-of-body prototypes ----------------------------------------
    extern function void oobNoParen145;
    extern function void oobParen145();
    extern task oobTaskPlain145;
    // ---- § qualLifetimeStubListsNoBodyLocals141 must NOT move -----------
    local function automatic int qualLife145(int z);
      int ql = 2;
      return ql + z;
    endfunction
  endclass

  class Second145;
    int sv;
    int acc2;
    function new;                 // PAREN-LESS constructor: § 142v
      int dn = 31;
      sv = dn;
      acc2 = dn;
    endfunction
  endclass

  function void Holder145::oobNoParen145;
    int oi = 51;
    oi = oi * 2;
    acc = oi;
  endfunction

  function void Holder145::oobParen145();
    int oi = 51;
    oi = oi * 2;
    acc = oi;
  endfunction

  task Holder145::oobTaskPlain145;   // no body io => BLOCK-ITEM
    int ot = 61;
    ot = ot + 1;
    acc = ot;
  endtask

  // ---- package FREE subroutines ----------------------------------------
  function int freeNoParen145;
    int fi = 71;
    fi = fi - 1;
    return fi;
  endfunction

  function int freeParen145();
    int fi = 71;
    fi = fi - 1;
    return fi;
  endfunction

  task freeTaskIo145;              // body io => TF-ITEM task
    input int arg9;
    int ft = 61;
    ft = ft + arg9;
    $display(ft);
  endtask

endpackage

module mc145;
  import pc145::*;
  int mres;

  function void modNoParen145;
    int mi = 81;
    mi = mi + 1;
    $display(mi);
  endfunction

  function void modParen145();
    int mi = 81;
    mi = mi + 1;
    $display(mi);
  endfunction

  task modTaskIo145;
    input int mb;
    int mt = 91;
    mt = mt + mb;
    $display(mt);
  endtask

  task modTaskNoIo145;
    int mt = 91;
    mt = mt + 1;
    $display(mt);
  endtask

  initial begin
    modNoParen145();
    modParen145();
    modTaskIo145(2);
    modTaskNoIo145();
    mres = 0;
  end
endmodule

program pg145;
  function void prgNoParen145;
    int pi = 101;
    pi = pi + 1;
    $display(pi);
  endfunction
  function void prgParen145();
    int pi = 101;
    pi = pi + 1;
    $display(pi);
  endfunction
  initial begin
    prgNoParen145();
    prgParen145();
  end
endprogram

interface if145;
  function void ifcNoParen145;
    int ii = 111;
    ii = ii + 1;
    $display(ii);
  endfunction
  function void ifcParen145();
    int ii = 111;
    ii = ii + 1;
    $display(ii);
  endfunction
endinterface
