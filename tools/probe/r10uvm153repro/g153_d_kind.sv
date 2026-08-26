// r10uvm153 arm D — THE LISTING: which ENTRY the name finds, and in what
// ORDER.  Surelog `break`s on the FIRST entry of the name in the package's
// `Variables()` vector, and that vector is source-ordered with the hoisted
// out-of-body constructor locals interleaved, so a hoisted local declared
// EARLIER than a real package variable of the same name WINS.  LHS is golden.
package pd153;

  class Kd153;
    int fd;
  endclass

  // (1) A hoisted constructor local declared BEFORE the real package variable
  //     of the same name.  Golden's listing order decides.
  class Ed153;
    extern function new(int q);
  endclass
  function Ed153::new(int q);
    int d_first;              // hoisted at line 18 -> listing slot 0
    d_first = q;
  endfunction

  int    d_first;             // the REAL package variable, line 21

  // (2) every declarator kind the listing carries
  int      d_int;
  string   d_str;
  bit      d_bit;
  logic    d_log;
  real     d_real;
  chandle  d_ch;
  Kd153    d_cls;
  typedef enum { D_A, D_B } d_e;
  d_e      d_enum;
  typedef logic [3:0] d_nib;
  d_nib    d_net;             // a USER TYPEDEF over a packed vector -> a NET,
                              // not a variable: the listing must NOT hold it
  int      d_arr[2];          // an UNPACKED ARRAY -> array_var in golden

  // (3) three declarators on one line
  int d_m1, d_m2, d_m3;

  class Rd153;
    int      d_first;
    int      d_int;
    string   d_str;
    bit      d_bit;
    logic    d_log;
    real     d_real;
    chandle  d_ch;
    Kd153    d_cls;
    d_e      d_enum;
    d_nib    d_net;
    int      d_arr[2];
    int      d_m1, d_m2, d_m3;
    extern function void rd153(int p);
  endclass

  function void Rd153::rd153(int p);
    d_first = p;              // FIRST-MATCH-WINS: hoisted local or pkg var?
    d_int   = p;
    d_str   = "s";
    d_bit   = 1'b1;
    d_log   = 1'b0;
    d_real  = 1.0;
    d_cls   = null;
    d_enum  = D_A;
    d_net   = 4'h3;           // the name is a NET, not in Variables()
    d_arr[0] = p;             // an unpacked-array element
    d_m1    = p;
    d_m2    = p;
    d_m3    = p;
  endfunction

endpackage
