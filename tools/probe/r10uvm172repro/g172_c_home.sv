// r10uvm172 arm C — HOMES.  The SAME statement (a two-deep call whose base
// identifier names the enclosing subroutine) written in every home a corpus
// body can have.  MEASUREMENT ONLY.
package pe172;
  class bag172;
    string bq172[$];
    int    bn172;
    function void badd172(string s); bq172.push_back(s); endfunction
  endclass

  // C1 — package FREE function, return-name receiver.
  function bag172 pkgcpy172();
    pkgcpy172 = new();
    pkgcpy172.bq172.push_back("c1");
    pkgcpy172.badd172("c1u");
    return pkgcpy172;
  endfunction

  // C2 — package FREE task, local named after the task.
  task pkgtsk172();
    bag172 pkgtsk172v;
    pkgtsk172v = new();
    pkgtsk172v.bq172.push_back("c2");
  endtask

  class oob172;
    string oq172[$];
    extern function oob172 oobcpy172();
    function bag172 inbody172();
      inbody172 = new();
      inbody172.bq172.push_back("c4");
      return inbody172;
    endfunction
  endclass

  // C3 — OUT-OF-BODY class method, return-name receiver.
  function oob172 oob172::oobcpy172();
    oobcpy172 = new();
    oobcpy172.oq172.push_back("c3");
    return oobcpy172;
  endfunction
endpackage

// C5 — a package that WILDCARD-IMPORTS pe172, so every body above is CLONED
// into it (the clone axis uvm171/uvm148 name).
package pf172;
  import pe172::*;
  function int usepe172();
    bag172 b172;
    b172 = pkgcpy172();
    return b172.bq172.size();
  endfunction
endpackage

module topc172;
  import pe172::*;
  bag172 modbag172;

  // C6 — MODULE function, return-name receiver.
  function bag172 modcpy172();
    modcpy172 = new();
    modcpy172.bq172.push_back("c6");
    return modcpy172;
  endfunction

  // C7 — MODULE task, local named after the task.
  task modtsk172();
    bag172 modtsk172v;
    modtsk172v = new();
    modtsk172v.bq172.push_back("c7");
  endtask

  initial begin
    modbag172 = modcpy172();
    modtsk172();
    void'(pkgcpy172());
    pkgtsk172();
  end
endmodule
