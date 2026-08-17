// r10uvm81 VERIFIER arm A — LAW 1 boundary: package variables of EVERY KIND,
// INIT and DECLARATION SPELLING, each colliding with a package subroutine's
// FORMAL of the same name.  The brief asks: "probe package vars of every
// kind/init/visibility spelling".  Each cell is one `<kind>_v` name declared
// BOTH as a package variable and as a formal of a package function.
package pa91;

  // --- DECLARED package variables, one per kind/spelling -------------------
  int              i_v;
  int              i_init_v = 7;              // INITIALIZED at declaration
  byte             b_v;
  bit [7:0]        bv_v;
  logic [3:0]      lg_v;
  reg              rg_v;
  real             re_v;
  shortreal        sr_v;
  string           st_v;
  chandle          ch_v;
  event            ev_v;
  time             tm_v;
  integer          ig_v;
  var int          var_v;                     // explicit `var`
  const int        cst_v = 3;                 // const variable
  int              arr_v [4];                 // unpacked array
  int              dyn_v [];                  // dynamic array
  int              que_v [$];                 // queue
  int              asc_v [string];            // associative array
  typedef enum { E0, E1 } e_t;
  e_t              en_v;
  typedef struct packed { logic a; logic b; } sp_t;
  sp_t             sps_v;
  typedef struct { int a; int b; } su_t;
  su_t             sus_v;
  typedef union packed { logic [1:0] a; logic [1:0] b; } un_t;
  un_t             un_v;
  typedef logic [7:0] byte_t;
  byte_t           td_v;                      // typedef'd
  int unsigned     iu_v;
  int signed       is_v;

  class cls91;
    int m_a;
  endclass
  cls91            cl_v;                      // CLASS HANDLE package variable

  int sink91;
  real rsink91;
  string ssink91;

  // --- one package function per cell: formal SHADOWS the package variable ---
  function void f_i     (int          i_v);      sink91  = i_v;     endfunction
  function void f_iinit (int          i_init_v);  sink91  = i_init_v; endfunction
  function void f_b     (byte         b_v);      sink91  = b_v;     endfunction
  function void f_bv    (bit [7:0]    bv_v);     sink91  = bv_v;    endfunction
  function void f_lg    (logic [3:0]  lg_v);     sink91  = lg_v;    endfunction
  function void f_rg    (reg          rg_v);     sink91  = rg_v;    endfunction
  function void f_re    (real         re_v);     rsink91 = re_v;    endfunction
  function void f_sr    (shortreal    sr_v);     rsink91 = sr_v;    endfunction
  function void f_st    (string       st_v);     ssink91 = st_v;    endfunction
  function void f_ch    (chandle      ch_v);     sink91  = (ch_v == null); endfunction
  function void f_tm    (time         tm_v);     sink91  = tm_v;    endfunction
  function void f_ig    (integer      ig_v);     sink91  = ig_v;    endfunction
  function void f_var   (int          var_v);    sink91  = var_v;   endfunction
  function void f_cst   (int          cst_v);    sink91  = cst_v;   endfunction
  function void f_arr   (int          arr_v [4]); sink91 = arr_v[0]; endfunction
  function void f_que   (int          que_v [$]); sink91 = que_v.size(); endfunction
  function void f_en    (e_t          en_v);     sink91  = int'(en_v); endfunction
  function void f_sps   (sp_t         sps_v);    sink91  = sps_v.a; endfunction
  function void f_sus   (su_t         sus_v);    sink91  = sus_v.a; endfunction
  function void f_un    (un_t         un_v);     sink91  = un_v.a;  endfunction
  function void f_td    (byte_t       td_v);     sink91  = td_v;    endfunction
  function void f_iu    (int unsigned iu_v);     sink91  = iu_v;    endfunction
  function void f_is    (int signed   is_v);     sink91  = is_v;    endfunction
  function void f_cl    (cls91        cl_v);     sink91  = cl_v.m_a; endfunction

  // --- FORMAL DIRECTION spellings: input / output / inout / ref / const ref -
  int di_v, dof_v, dio_v, dr_v, dcr_v;
  function void f_din  (input  int di_v);   sink91 = di_v;   endfunction
  function void f_dout (output int dof_v);  dof_v  = sink91; endfunction
  function void f_dio  (inout  int dio_v);  dio_v  = dio_v + 1; endfunction
  function automatic void f_dref (ref    int dr_v);   sink91 = dr_v;   endfunction
  function automatic void f_dcr  (const ref int dcr_v); sink91 = dcr_v; endfunction

  // --- a formal with a DEFAULT VALUE that itself names the collider ---------
  int dv_v;
  function void f_dv (int dv_v = 5);  sink91 = dv_v;  endfunction

  // --- a TASK formal spelling set ------------------------------------------
  int tk_v;
  task t_tk (int tk_v);  sink91 = tk_v;  endtask

endpackage
