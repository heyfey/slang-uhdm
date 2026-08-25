// r10uvm139 arm B — every DECLARATION KIND a subroutine local can have, under
// both productions, with the three written lifetimes and with/without an
// initialiser.  Names deliberately unlike arm A's.
package Forge139;

  typedef enum {SLAG139, DROSS139} temper139_e;
  typedef struct packed { bit [3:0] hi; bit [3:0] lo; } billet139_s;
  typedef int weld139_t;

  class Tongs139;
    int spark;
    function new(); spark = 0; endfunction
  endclass

  // ---- TF-ITEM production (paren-less function) ----
  function void tfKinds139;
    int            a1;
    static int     a2;
    automatic int  a3;
    int            a4 = 7;
    static int     a5 = 7;
    automatic int  a6 = 7;
    logic [7:0]    b1;
    static logic [7:0] b2;
    automatic logic [7:0] b3;
    bit            c1;
    static bit     c2;
    real           d1;
    static real    d2;
    temper139_e    e1;
    static temper139_e e2;
    billet139_s    f1;
    static billet139_s f2;
    weld139_t      g1;
    static weld139_t g2;
    string         h1[$];
    static string  h2[$];
    int            i1[];
    static int     i2[];
    int            j1[4];
    static int     j2[4];
    int            k1[string];
    static int     k2[string];
    Tongs139       l1;
    static Tongs139 l2;
    Tongs139       l3 = null;
    static Tongs139 l4 = null;
    byte           o1;
    static byte    o2;
    shortint       p1;
    static shortint p2;
    longint        q1;
    static longint q2;
    time           r1;
    static time    r2;
    integer        s1;
    static integer s2;
    reg  [3:0]     t1;
    static reg [3:0] t2;
    a1 = a2;
  endfunction

  // ---- BLOCK production (parenthesised function): the OTHER rule ----
  function void blkKinds139();
    int            u1;
    static int     u2;
    automatic int  u3;
    int            u4 = 7;
    static int     u5 = 7;
    automatic int  u6 = 7;
    string         u7[$];
    static string  u8[$];
    int            u9[4];
    static int     ua[4];
    int            ub[string];
    static int     uc[string];
    Tongs139       ud;
    static Tongs139 ue;
    temper139_e    uf;
    static temper139_e ug;
    billet139_s    uh;
    static billet139_s ui;
    u1 = u2;
  endfunction

  // ---- TF-ITEM production, TASK with a body io declaration ----
  task tfTask139;
    input int v0;
    int        v1;
    static int v2;
    automatic int v3;
    string     v4[$];
    static string v5[$];
    v1 = v2;
  endtask

endpackage
