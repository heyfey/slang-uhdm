// v11u80 q4 -- THE ELEMENT CLASS TABLE, and the classes hoistElemClass80
// DECLINES.  The builder mints fourteen classes and returns ArraySkip for the
// rest; a class it mints WRONG is an invention, and a class it declines where
// golden writes a holder is a missed conversion.  Asked here: every integral
// atom net- and variable-declared where legal, the two floats, string, time,
// a packed 2-D element, a packed struct with 2-STATE members (the
// structMembersAllLogic77 predicate's other side), a packed struct whose
// member is itself a packed struct, and an enum with an INT base.
package pq4;
  typedef struct packed { logic [7:0] x; logic [7:0] y; }   sl_t;
  typedef struct packed { bit [7:0] x; bit [7:0] y; }       sb_t;  // 2-state
  typedef struct packed { sl_t a; logic [3:0] b; }          sn_t;  // nested
  typedef enum int { EA, EB }                                ei_t;  // int base
  typedef enum logic [1:0] { LA, LB }                        el_t;
  typedef bit [7:0]  b_t;
  typedef logic [7:0] w_t;

  int        e_int   [0:1];
  integer    e_integ [0:1];
  shortint   e_shrt  [0:1];
  longint    e_long  [0:1];
  byte       e_byte  [0:1];
  time       e_time  [0:1];
  bit  [7:0] e_bit   [0:1];
  real       e_real  [0:1];
  shortreal  e_sreal [0:1];
  string     e_str   [0:1];
  logic [7:0] e_log  [0:1];
  reg   [7:0] e_reg  [0:1];
  logic [3:0][7:0] e_pk2 [0:1];   // packed 2-D element
  b_t        e_tdbit [0:1];       // 2-state typedef element
  w_t        e_tdw   [0:1];
  sb_t       e_sb    [0:1];       // 2-state-member packed struct
  sn_t       e_sn    [0:1];       // nested packed struct
  wire sn_t  e_nsn   [0:1];       // ... net-declared
  ei_t       e_ei    [0:1];       // int-based enum
  el_t       e_el    [0:1];
  wire el_t  e_nel   [0:1];
endpackage

module dut (output logic [31:0] o);
  import pq4::*;
  assign o = e_int[0] ^ e_integ[0] ^ {16'd0, e_shrt[0]} ^ e_long[0][31:0]
           ^ {24'd0, e_byte[0]} ^ e_time[0][31:0] ^ {24'd0, e_bit[0]}
           ^ {31'd0, e_real[0] > 0.0} ^ {31'd0, e_sreal[0] > 0.0}
           ^ {31'd0, e_str[0] == "a"} ^ {24'd0, e_log[0]} ^ {24'd0, e_reg[0]}
           ^ e_pk2[0] ^ {24'd0, e_tdbit[0]} ^ {24'd0, e_tdw[0]}
           ^ {16'd0, e_sb[0]} ^ {12'd0, e_sn[0]} ^ {12'd0, e_nsn[0]}
           ^ e_ei[0] ^ {30'd0, e_el[0]} ^ {30'd0, e_nel[0]};
endmodule
