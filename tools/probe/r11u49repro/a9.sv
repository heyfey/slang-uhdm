// r11u49 arm a9 -- WHERE a member select must be written for the ELAB package
// listing to flatten.  Eight packed-struct package localparams, identical in
// every way, each selected in exactly ONE syntactic context.
package p;
  typedef struct packed { logic [7:0] CTL; logic [7:0] DAT; } pb_t;
  localparam pb_t S_NONE = '{CTL:0, DAT:1};   // never selected
  localparam pb_t S_PARM = '{CTL:0, DAT:2};   // package PARAMETER declaration
  localparam pb_t S_TDEF = '{CTL:0, DAT:3};   // package TYPEDEF dimension
  localparam pb_t S_FUNC = '{CTL:0, DAT:4};   // package FUNCTION body
  localparam pb_t S_MPAR = '{CTL:0, DAT:5};   // MODULE parameter declaration
  localparam pb_t S_MTDF = '{CTL:0, DAT:6};   // MODULE typedef dimension
  localparam pb_t S_MASN = '{CTL:0, DAT:7};   // MODULE continuous assign
  localparam pb_t S_MPRT = '{CTL:0, DAT:8};   // MODULE parameter PORT list
  localparam int  USE_PARM = S_PARM.DAT;
  typedef struct packed { logic [S_TDEF.DAT-1:0] w; } tdef_t;
  function automatic int f(); return S_FUNC.DAT; endfunction
endpackage
module a9 #(parameter int MPRT = p::S_MPRT.DAT) (output logic [31:0] o);
  localparam int MPAR = p::S_MPAR.DAT;
  typedef struct packed { logic [p::S_MTDF.DAT-1:0] v; } mt_t;
  mt_t mv;
  assign o = p::S_MASN.DAT + MPAR + MPRT + mv.v + p::USE_PARM + p::f();
endmodule
