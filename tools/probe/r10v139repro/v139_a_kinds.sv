// r10v139 arm A — DECLARATION KINDS x WRITTEN LIFETIME x +/- INITIALISER,
// under the TF-ITEM production (a paren-less package free function) and, for
// the same declarations, under the BLOCK production (the parened twin).
// Names deliberately unlike the implementer's grid.
package Quarrel139;
  typedef enum {ZED139, YAK139, XI139} Tally139;
  typedef struct packed { bit [3:0] hi; bit [3:0] lo; } Packet139;
  typedef struct { int wide; string tag; } Loose139;
  class Trinket139;
    int junk139;
  endclass

  // ---- TF-ITEM face, NOTHING written -------------------------------------
  function void plainNone139;
    int          ka;
    string       kb;
    string       kc[$];
    int          kd[];
    int          ke[string];
    bit [7:0]    kf[4];
    Trinket139   kg;
    Packet139    kh;
    real         ki;
    Loose139     kj;
    Tally139     kk;
    ka = 1; kb = "x"; ki = 0.5;
  endfunction

  // ---- TF-ITEM face, `static` written ------------------------------------
  function void plainStat139;
    static int          la;
    static string       lb;
    static string       lc[$];
    static int          ld[];
    static int          le[string];
    static bit [7:0]    lf[4];
    static Trinket139   lg;
    static Packet139    lh;
    static real         li;
    static Loose139     lj;
    static Tally139     lk;
    la = 1; lb = "x"; li = 0.5;
  endfunction

  // ---- TF-ITEM face, `automatic` written ---------------------------------
  function void plainAuto139;
    automatic int          ma;
    automatic string       mb;
    automatic string       mc[$];
    automatic int          md[];
    automatic int          me[string];
    automatic bit [7:0]    mf[4];
    automatic Trinket139   mg;
    automatic Packet139    mh;
    automatic real         mi;
    automatic Loose139     mj;
    automatic Tally139     mk;
    ma = 1; mb = "x"; mi = 0.5;
  endfunction

  // ---- TF-ITEM face, INITIALISED, nothing written ------------------------
  function void plainInit139;
    int          na = 7;
    string       nb = "seven";
    string       nc[$] = {"a","b"};
    int          nd[] = new[3];
    bit [7:0]    nf[4] = '{1,2,3,4};
    Trinket139   ng = null;
    Packet139    nh = 8'hA5;
    real         ni = 1.25;
    Tally139     nk = YAK139;
    na = na + 1;
  endfunction

  // ---- TF-ITEM face, INITIALISED, `static` written -----------------------
  function void statInit139;
    static int          oa = 7;
    static string       ob = "seven";
    static string       oc[$] = {"a","b"};
    static bit [7:0]    of[4] = '{1,2,3,4};
    static Trinket139   og = null;
    static real         oi = 1.25;
    oa = oa + 1;
  endfunction

  // ---- TF-ITEM face, INITIALISED, `automatic` written --------------------
  function void autoInit139;
    automatic int          pa = 7;
    automatic string       pb = "seven";
    automatic string       pc[$] = {"a","b"};
    automatic bit [7:0]    pf[4] = '{1,2,3,4};
    automatic Trinket139   pg = null;
    automatic real         pi = 1.25;
    pa = pa + 1;
  endfunction

  // ---- BLOCK face twins (parened header) ---------------------------------
  function void blkNone139();
    int          qa;
    string       qb;
    string       qc[$];
    Trinket139   qg;
    real         qi;
    qa = 1; qb = "x"; qi = 0.5;
  endfunction

  function void blkStat139();
    static int          ra;
    static string       rb;
    static string       rc[$];
    static Trinket139   rg;
    static real         ri;
    ra = 1; rb = "x"; ri = 0.5;
  endfunction

  function void blkAuto139();
    automatic int          sa;
    automatic string       sb;
    automatic string       sc[$];
    automatic Trinket139   sg;
    automatic real         si;
    sa = 1; sb = "x"; si = 0.5;
  endfunction

  function void blkInit139();
    int          ta = 7;
    automatic string tb = "seven";
    static real  ti = 1.25;
    ta = ta + 1;
  endfunction
endpackage
