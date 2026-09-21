// r11u79 z8 — THE QUALIFIERS AND THE NEGATIVES.  `elabSignal`'s declaration
// clause reads `sig->isConst()`, `sig->isVar()` and `!sig->isStatic()` before
// it ever reaches the typespec, so a qualifier alone can move a package
// declaration out of the Nets vector; and the initializer, the visibility and
// the automatic flag are the compared fields of whatever object it lands in.
// The NEGATIVES ask what golden writes NOTHING for, so the law never mints an
// object golden lacks (the 73/74/77 break class).
package pq;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } st_t;
  typedef enum logic [1:0] { EA, EB } en_t;

  const st_t        q_cst   = '{8'd1, 8'd2};   // CONST all-logic struct
  var   st_t        q_vst;                     // VAR-qualified struct
  st_t              q_st;                      // plain
  wire  st_t        q_wst;                     // wire-declared
  static st_t       q_sst;                     // STATIC-qualified
  const logic [7:0] q_clog  = 8'd3;
  var   logic [7:0] q_vlog;
  static logic[7:0] q_slog;
  const int         q_cint  = 4;
  const en_t        q_cen   = EA;
  st_t              q_init  = '{8'd5, 8'd6};   // an INITIALIZED net-kind decl
  logic [7:0]       q_ilog  = 8'd7;

  // NEGATIVES: things the listing must not invent an object for.
  typedef logic [7:0] q_tdonly;                // a typedef, not a declaration
  parameter int     q_param = 9;               // a parameter, not a variable
  localparam int    q_lparam = 10;
  function automatic int q_f(); q_f = 11; endfunction   // a subroutine local
  class q_cls; int m; endclass
  q_cls             q_ch;                      // a class handle
  chandle           q_chd;
  event             q_ev;
endpackage

module dut (output logic [31:0] o);
  import pq::*;
  assign o = {16'd0, q_st} ^ {16'd0, q_init} ^ {24'd0, q_ilog}
           ^ {24'd0, q_clog} ^ q_cint ^ q_param;
endmodule
