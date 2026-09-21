// v11u79 q4 — UNPACKED SPELLINGS.  emitPkgFixedArrayVar79 requires a written
// DECLARATOR dimension, multiplies every fixed level for vpiSize in the
// elaborated view, moves vpiSigned onto the HOLDER and clears the element's.
// These are the spellings the implementer's z5 did not carry.
package q4;
  typedef struct packed { int x; logic [7:0] y; } si_t;   // -> struct_var element
  typedef struct packed { logic [7:0] a; logic [7:0] b; } sl_t; // all-logic -> net
  typedef enum logic [1:0] { EA, EB } en_t;
  parameter int N = 3;
  logic [7:0]  u_sizeonly [3];          // a SIZE-ONLY dimension
  logic [7:0]  u_2d [0:1][0:2];         // multi-dim, flattened 6
  logic [7:0]  u_deg [0:0];             // a DEGENERATE size-1 dimension
  logic [7:0]  u_param [0:N-1];         // a PARAMETER-sized dimension
  logic [7:0]  u_desc [3:0];            // a DESCENDING dimension
  int signed   u_intsigned [0:1];       // signedness on the holder
  byte         u_byte [0:1];
  shortint     u_shortint [0:1];
  si_t         u_si [0:1];              // array of struct_var
  sl_t         u_sl [0:1];              // all-logic struct: a flat net?
  en_t         u_en [0:1];
  wire [7:0]   u_wire [0:1];            // a NET-declared unpacked array
  typedef logic [7:0] tarr_t [0:1];
  tarr_t       u_tdarr;                 // a TYPEDEF'd unpacked array: no declarator dim
  real         u_real [0:1];
  string       u_str [0:1];
endpackage

module dut (output logic [31:0] o);
  import q4::*;
  assign o = {24'd0, u_sizeonly[0]} ^ {24'd0, u_2d[0][0]} ^ {24'd0, u_deg[0]}
           ^ {24'd0, u_param[0]} ^ {24'd0, u_desc[0]} ^ u_intsigned[0]
           ^ {24'd0, u_byte[0]} ^ {16'd0, u_shortint[0]}
           ^ {16'd0, u_sl[0]} ^ {30'd0, u_en[0]} ^ {24'd0, u_wire[0]}
           ^ {24'd0, u_tdarr[0]};
endmodule
