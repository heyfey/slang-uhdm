// r10earl9 witness D — the OTHER half of the bound-fold family: the read is a
// MODULE-LOCAL LOCALPARAM, not a package member.
//   rv_timer.sv:27:10   `localparam int N_HARTS = 1;`  then
//                       `logic [N_HARTS-1:0] active;`     -> golden constant
//   usbdev.sv:140:10    `localparam int NEndpoints = usbdev_reg_pkg::NEndpoints;`
//   sha2.sv:36:17       `logic [$clog2(NumRound)-1:0] round;` (pkg localparam)
// § crossPkgRangeBoundFold's g.sv distinguisher was "a module-LOCAL bound is
// NOT substituted — an overridable parameter has no value at definition-compile
// time".  A LOCALPARAM is NOT overridable, so the real cut should be
// OVERRIDABLE-vs-not, and this witness measures exactly that.
module ud #(
  parameter  int PO = 6           // OVERRIDABLE module parameter (control)
) (
  input  logic clk_i,
  output logic o
);
  localparam int LP = 4;          // module-local localparam
  localparam int LQ = LP + 1;     // ...computed from another localparam

  // row A — var decl bound reading a LOCALPARAM      (rv_timer / usbdev)
  logic [LP-1:0]            a_v;
  // row B — var decl bound reading the OVERRIDABLE parameter (control)
  logic [PO-1:0]            b_v;
  // row C — $clog2 of a LOCALPARAM                   (sha2)
  logic [$clog2(LP)-1:0]    c_v;
  // row D — $clog2 of the OVERRIDABLE parameter (control)
  logic [$clog2(PO)-1:0]    d_v;
  // row E — localparam DECLARED TYPE bound reading a localparam
  localparam logic [LP-1:0] E_P = '0;
  // row F — localparam DECLARED TYPE bound reading the parameter (control)
  localparam logic [PO-1:0] F_P = '0;
  // row G — a computed localparam as a bound
  logic [LQ-1:0]            g_v;
  // row H — an UNPACKED dim reading a localparam
  logic [7:0]               h_v [LP];
  // row I — a struct member bound reading a localparam
  typedef struct packed { logic [LP-1:0] x; } i_t;
  i_t                       i_v;

  assign o = clk_i ^ ^a_v ^ ^b_v ^ ^c_v ^ ^d_v ^ ^g_v ^ ^h_v[0] ^ ^i_v
             ^ ^E_P ^ ^F_P;
endmodule
