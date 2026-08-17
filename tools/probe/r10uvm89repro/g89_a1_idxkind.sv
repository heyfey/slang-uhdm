// r10uvm89 ARM a1 — WHICH INDEX KIND, and WHERE.  Read off GOLDEN only.
// Every statement is a DOTTED path `hh.<member>[<index>]` (the head's shape) so
// every one of them is a hier_path, and each index is a DIFFERENT kind, crossed
// with TRAILING (the select is the last path component) and MID (a `.f` follows)
// and with LVALUE / RVALUE / call-argument / condition / return position.
// Cell tags are in comments: A<n> = trailing, B<n> = mid.
package p89;

  typedef struct packed { int a; int b; } kt89;

  class inner89;
    int f;
    int g[4];
    function string nm(); return "n"; endfunction
  endclass

  class holder89;
    inner89 aidx[8];          // fixed array of handles
    inner89 amap[string];     // assoc, string key
    inner89 apat[kt89];       // assoc, struct key
    int q[$];                 // queue
    int pk;
    string s;
    function string gn(); return "k"; endfunction
  endclass

  function automatic int f89(int x); return x; endfunction

  class t89;
    holder89 hh;
    inner89  oo;
    int i;
    int ii[8];
    int pk;
    string s;
    int res;

    function string gn(); return "k"; endfunction

    // ---------------- IN-BODY class method, every index kind ----------------
    function void run();
      // A1  constant                     TRAIL  LVALUE
      hh.aidx[2] = null;
      // A2  identifier                   TRAIL  LVALUE
      hh.aidx[i] = null;
      // A3  operation                    TRAIL  LVALUE
      hh.aidx[i + 1] = null;
      // A4  plain func_call (this class)  TRAIL  LVALUE   <- THE HEAD's kind
      hh.amap[gn()] = null;
      // A5  this.call                    TRAIL  LVALUE
      hh.amap[this.gn()] = null;
      // A6  member.call                  TRAIL  LVALUE
      hh.amap[hh.gn()] = null;
      // A7  nested select (local array)   TRAIL  LVALUE
      hh.aidx[ii[i]] = null;
      // A8  member select (hier_path)     TRAIL  LVALUE
      hh.aidx[oo.f] = null;
      // A9  concat                       TRAIL  LVALUE
      hh.amap[{s, s}] = null;
      // A10 ternary                      TRAIL  LVALUE
      hh.aidx[i ? 1 : 2] = null;
      // A11 string literal               TRAIL  LVALUE
      hh.amap["lit"] = null;
      // A12 part-select index            TRAIL  LVALUE
      hh.aidx[pk[3:0]] = null;
      // A13 indexed part-select index    TRAIL  LVALUE
      hh.aidx[pk[1+:2]] = null;
      // A14 sys_func_call index          TRAIL  LVALUE
      hh.aidx[$clog2(8)] = null;
      // A15 package func_call index      TRAIL  LVALUE
      hh.aidx[f89(i)] = null;
      // A16 built-in method call index   TRAIL  LVALUE
      hh.aidx[hh.q.size()] = null;
      // A17 assignment pattern index     TRAIL  LVALUE
      hh.apat['{a: 1, b: 2}] = null;

      // ---- the SAME kinds in RVALUE / ARG / CONDITION / RETURN position ----
      // C1  func_call index  TRAIL  RVALUE
      oo = hh.amap[gn()];
      // C2  func_call index  TRAIL  CALL ARGUMENT
      res = f89(hh.aidx[gn().len()].f);
      // C3  hier_path index  TRAIL  RVALUE
      oo = hh.aidx[oo.f];
      // C4  hier_path index  TRAIL  CONDITION
      if (hh.aidx[oo.f] != null) res = 1;
      // C5  nested-select index TRAIL RVALUE
      oo = hh.aidx[ii[i]];
      // C6  func_call index  TRAIL  self-referencing RHS of the SAME lvalue
      hh.amap[gn()] = hh.amap[gn()];

      // ---------------- MID: a `.f` follows the select ----------------
      // B1  constant     MID  LVALUE
      hh.aidx[2].f = 1;
      // B2  identifier   MID  LVALUE
      hh.aidx[i].f = 1;
      // B3  operation    MID  LVALUE
      hh.aidx[i + 1].f = 1;
      // B4  func_call    MID  LVALUE
      hh.amap[gn()].f = 1;
      // B5  hier_path    MID  LVALUE
      hh.aidx[oo.f].f = 1;
      // B6  nested sel   MID  LVALUE
      hh.aidx[ii[i]].f = 1;
      // B7  func_call    MID  RVALUE
      res = hh.amap[gn()].f;
      // B8  hier_path    MID  RVALUE
      res = hh.aidx[oo.f].f;
      // B9  nested sel   MID  RVALUE
      res = hh.aidx[ii[i]].f;
      // B10 func_call    MID  CONDITION
      if (hh.amap[gn()].f == 0) res = 2;
      // B11 func_call    MID  CALL ARGUMENT
      res = f89(hh.amap[gn()].f);
      // B12 two dims, both unknown, MID
      hh.aidx[ii[i]].g[oo.f] = 3;
      // B13 method call ON the select (the m_streams[].exists shape)
      if (hh.amap.exists(gn())) res = 4;
      // B14 select then method call     (the BuildUVMPkg rung 46 shape)
      res = hh.amap[gn()].nm().len();
    endfunction

    extern function int oob89();
  endclass

  // ---------------- OUT-OF-BODY method ----------------
  function int t89::oob89();
    // D1 func_call index  TRAIL LVALUE (out-of-body)
    hh.amap[gn()] = null;
    // D2 hier_path index  TRAIL LVALUE (out-of-body)
    hh.aidx[oo.f] = null;
    // D3 func_call index  MID   LVALUE (out-of-body)
    hh.amap[gn()].f = 1;
    // D4 func_call index  TRAIL RVALUE (out-of-body)
    oo = hh.amap[gn()];
    return 0;
  endfunction

  // ---------------- PACKAGE function ----------------
  function automatic int pf89(holder89 hh, inner89 oo, int i);
    // E1 func_call index  TRAIL LVALUE (package function)
    hh.aidx[f89(i)] = null;
    // E2 hier_path index  TRAIL LVALUE (package function)
    hh.aidx[oo.f] = null;
    // E3 func_call index  MID   LVALUE (package function)
    hh.aidx[f89(i)].f = 1;
    // E4 hier_path index  TRAIL RVALUE (package function)
    oo = hh.aidx[oo.f];
    return 0;
  endfunction
endpackage

// ---------------- MODULE scope: always / initial / function ----------------
module m89;
  import p89::*;
  typedef struct packed { int x; int y; } st89;
  st89 sarr[8];
  int  jj[8];
  int  k;
  int  r;
  inner89 oo;
  holder89 hh;

  function automatic int mf89(int x); return x; endfunction

  initial begin
    // F1 module: func_call index  TRAIL LVALUE
    sarr[mf89(k)].x = 1;
    // F2 module: hier_path index  TRAIL LVALUE (dotted base)
    hh.aidx[oo.f] = null;
    // F3 module: nested select    TRAIL LVALUE (dotted base)
    hh.aidx[jj[k]] = null;
    // F4 module: func_call index  MID   LVALUE
    hh.amap[hh.gn()].f = 1;
    // F5 module: func_call index  TRAIL RVALUE
    oo = hh.amap[hh.gn()];
    // F6 module: hier_path index  TRAIL RVALUE
    oo = hh.aidx[oo.f];
  end

  always_comb begin
    // G1 always: nested select TRAIL LVALUE on a struct array member
    r = sarr[jj[k]].x;
  end
endmodule
