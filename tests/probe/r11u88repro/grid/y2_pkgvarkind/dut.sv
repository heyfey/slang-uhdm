// r11u77 y2 — LAW B: THE HOISTED HOLDER'S KIND, SHAPE BY SHAPE.
// `xe_impkind` measured two wrong cells (a struct package variable's holder
// is our `logic_var` where golden's is a `struct_net`; an unpacked-array
// package variable has no hoisted object at all).  `elabSignal`
// (NetlistElaboration.cpp:2050-2780) is the kind table: the typespec
// overrides the declaration -- a struct_typespec whose members are all
// logic/struct flips isNet back to TRUE.  This arm asks the whole table.
package pk;
  logic [15:0]      v_plain;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } st_t;
  st_t              v_struct;    // all-LOGIC members
  typedef struct packed { int x; logic [7:0] y; } si_t;
  si_t              v_structi;   // an INT member
  typedef struct packed { logic [3:0] a; st_t b; } sx_t;
  sx_t              v_structn;   // a nested STRUCT member
  typedef enum logic [1:0] { EA, EB } e_t;
  e_t               v_enum;
  logic [7:0]       v_uarr [0:1];  // UNPACKED array
  st_t              v_sarr [0:1];  // UNPACKED array of struct
  logic [1:0][7:0]  v_pkd;         // PACKED array
  int               v_int;
  byte              v_byte;
  bit               v_bit;
  real              v_real;
  string            v_str;
endpackage

module dut (output logic [31:0] o);
  import pk::*;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] v_plain;   assign v_plain   = 32'd1;
    logic [31:0] v_struct;  assign v_struct  = 32'd2;
    logic [31:0] v_structi; assign v_structi = 32'd3;
    logic [31:0] v_structn; assign v_structn = 32'd4;
    logic [31:0] v_enum;    assign v_enum    = 32'd5;
    logic [31:0] v_uarr;    assign v_uarr    = 32'd6;
    logic [31:0] v_sarr;    assign v_sarr    = 32'd7;
    logic [31:0] v_pkd;     assign v_pkd     = 32'd8;
    logic [31:0] v_int;     assign v_int     = 32'd9;
    logic [31:0] v_byte;    assign v_byte    = 32'd10;
    logic [31:0] v_bit;     assign v_bit     = 32'd11;
    logic [31:0] v_real;    assign v_real    = 32'd12;
    logic [31:0] v_str;     assign v_str     = 32'd13;
  end
  assign o = gv[0].v_plain ^ gv[0].v_struct ^ gv[0].v_structi ^ gv[0].v_structn
           ^ gv[0].v_enum  ^ gv[0].v_uarr   ^ gv[0].v_sarr    ^ gv[0].v_pkd
           ^ gv[0].v_int   ^ gv[0].v_byte   ^ gv[0].v_bit
           ^ gv[0].v_real  ^ gv[0].v_str;
endmodule
