// v11u77 vh -- the UNPACKED WRAPPER'S net-or-variable decision.  hoistKind77
// tests isNetDecl77 BEFORE the element's typespec, where the SCALAR path tests
// the struct FIRST.  Asked of golden for every element kind, net-declared and
// variable-declared side by side.
package pv;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } sl_t;   // all-logic
  typedef struct packed { int x; logic [7:0] y; }         si_t;   // int member
  typedef union  packed { logic [15:0] a; logic [15:0] b; } un_t;
  typedef enum logic [1:0] { VA, VB } en_t;
  wire  [7:0] a_nlog  [0:1];   // net, logic element      (measured: array_net)
  logic [7:0] a_vlog  [0:1];   // var, logic element      (measured: array_var)
  wire  sl_t  a_nsl   [0:1];   // net, all-logic struct
  sl_t        a_vsl   [0:1];   // var, all-logic struct   (measured: array_net)
  wire  si_t  a_nsi   [0:1];   // net, int-member struct
  si_t        a_vsi   [0:1];   // var, int-member struct
  wire  un_t  a_nun   [0:1];   // net, packed union
  un_t        a_vun   [0:1];   // var, packed union
  wire  en_t  a_nen   [0:1];   // net, enum
  en_t        a_ven   [0:1];   // var, enum
endpackage

module dut (output logic [31:0] o);
  import pv::*;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] a_nlog; assign a_nlog = 32'd1;
    logic [31:0] a_vlog; assign a_vlog = 32'd2;
    logic [31:0] a_nsl;  assign a_nsl  = 32'd3;
    logic [31:0] a_vsl;  assign a_vsl  = 32'd4;
    logic [31:0] a_nsi;  assign a_nsi  = 32'd5;
    logic [31:0] a_vsi;  assign a_vsi  = 32'd6;
    logic [31:0] a_nun;  assign a_nun  = 32'd7;
    logic [31:0] a_vun;  assign a_vun  = 32'd8;
    logic [31:0] a_nen;  assign a_nen  = 32'd9;
    logic [31:0] a_ven;  assign a_ven  = 32'd10;
  end
  assign o = gv[0].a_nlog ^ gv[0].a_vlog ^ gv[0].a_nsl ^ gv[0].a_vsl
           ^ gv[0].a_nsi  ^ gv[0].a_vsi  ^ gv[0].a_nun ^ gv[0].a_vun
           ^ gv[0].a_nen  ^ gv[0].a_ven;
endmodule
