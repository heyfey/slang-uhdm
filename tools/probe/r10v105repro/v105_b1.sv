// r10v105 arm b1 — SHAPES the implementer's grid never wrote.  MEASUREMENT ONLY.
package pb1;

  class dbase1;   int bx; endclass
  class dbase2;   int by; endclass
  class dbase3;   int bz; endclass

  typedef struct packed { logic [3:0] a; } st_b1_t;
  typedef enum { EA, EB } en_b1_t;
  typedef int  tdint_b1_t;

  // a class whose type parameter defaults to a STRUCT
  class cs_b1 #(type ST = st_b1_t);
    extern function void sm();
    function void sm_ib(); ST ib_s; endfunction
  endclass
  function void cs_b1::sm();
    ST xo_s;                     // OOB local, struct-defaulted type parameter
  endfunction

  // a class whose type parameter defaults to an ENUM
  class ce_b1 #(type ET = en_b1_t);
    extern function void em();
  endclass
  function void ce_b1::em();
    ET xo_e;                     // OOB local, enum-defaulted
  endfunction

  // a class whose type parameter defaults to a TYPEDEF of int
  class ct_b1 #(type TT = tdint_b1_t);
    extern task tm();
  endclass
  task ct_b1::tm();
    TT xo_tt;                    // OOB local, typedef-defaulted
  endtask

  // a VIRTUAL method defined out of body
  class cv_b1 #(type VT = dbase1);
    extern virtual function void vm();
    extern protected function void pm();
    extern local function void lm();
  endclass
  function void cv_b1::vm();
    VT xo_v;                     // OOB local in a VIRTUAL method
  endfunction
  function void cv_b1::pm();
    VT xo_p;                     // OOB local in a PROTECTED method
  endfunction
  function void cv_b1::lm();
    VT xo_l;                     // OOB local in a LOCAL method
  endfunction

  // a parameterised typedef built FROM the parameter, and a nested class
  class holder_b1 #(type HT = dbase1);
    int hx;
  endclass
  class cw_b1 #(type WT = dbase2);
    typedef holder_b1#(WT) wrap_t;   // a PARAMETERISED typedef of the parameter
    extern function void wm();
  endclass
  function void cw_b1::wm();
    wrap_t   xo_wrap;            // named by the TYPEDEF -> must RESOLVE
    WT       xo_w;               // the bare parameter   -> the law
  endfunction

  // THREE specialisations of one class, all used
  class c3_b1 #(type QT = dbase1);
    extern function void qm();
  endclass
  function void c3_b1::qm();
    QT xo_q;
  endfunction

endpackage

module topb1;
  import pb1::*;
  cs_b1        h_s;
  ce_b1        h_e;
  ct_b1        h_t;
  cv_b1        h_v;
  cw_b1        h_w;
  c3_b1 #(dbase1) h_q1;
  c3_b1 #(dbase2) h_q2;
  c3_b1 #(dbase3) h_q3;
  initial begin
    h_s = new(); h_e = new(); h_t = new(); h_v = new(); h_w = new();
    h_q1 = new(); h_q2 = new(); h_q3 = new();
  end
endmodule
