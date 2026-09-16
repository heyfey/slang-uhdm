// r11u49 arm b1 -- WHERE a member select must be written, with NO scoped
// `p::NAME` reference anywhere (the module wildcard-imports).  Only the
// member-select trigger can flatten these, so the arm is unconfounded.
package p;
  typedef struct packed { logic [7:0] CTL; logic [7:0] DAT; } pb_t;
  localparam pb_t S_NONE = '{CTL:0, DAT:1};   // never selected
  localparam pb_t S_PARM = '{CTL:0, DAT:2};   // package PARAMETER declaration
  localparam pb_t S_TDEF = '{CTL:0, DAT:3};   // package TYPEDEF dimension
  localparam pb_t S_FUNC = '{CTL:0, DAT:4};   // package FUNCTION body
  localparam pb_t S_VDEC = '{CTL:0, DAT:5};   // package VARIABLE declaration dim
  localparam pb_t S_MPAR = '{CTL:0, DAT:6};   // MODULE localparam declaration
  localparam pb_t S_MTDF = '{CTL:0, DAT:7};   // MODULE typedef dimension
  localparam pb_t S_MASN = '{CTL:0, DAT:8};   // MODULE continuous assign
  localparam int  USE_PARM = S_PARM.DAT;
  typedef struct packed { logic [S_TDEF.DAT-1:0] w; } tdef_t;
  function automatic int f(); return S_FUNC.DAT; endfunction
  logic [S_VDEC.DAT-1:0] pkgvar;
endpackage
module b1 import p::*; (output logic [31:0] o);
  localparam int MPAR = S_MPAR.DAT;
  typedef struct packed { logic [S_MTDF.DAT-1:0] v; } mt_t;
  mt_t mv;
  assign o = S_MASN.DAT + MPAR + mv.v + USE_PARM + f() + $bits(tdef_t) + $bits(pkgvar);
endmodule
