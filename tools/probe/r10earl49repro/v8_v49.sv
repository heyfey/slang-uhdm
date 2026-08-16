// v8 (VERIFIER) — the DANGEROUS direction of `srlgClassify49`: it returns
// RefConst for EVERY `SymbolKind::Parameter`, i.e. it assumes UHDM's
// `getValue(name, ...)` always succeeds.  When getValue returns null the
// pre-scan STOPS the walk, so any local parameter whose value the reducer
// cannot produce is an OVER-FIRE: we would keep walking and rewrite a later
// parameter golden leaves LOCATED.
//
// Each cell puts a COMPLEX-VALUED local parameter at operand0 of a concat and a
// plain parameter at operand1 as the reporter.  Golden LOCATED on the reporter
// means the probe STOPPED the walk and we over-fire.
typedef struct packed { logic [15:0] a; logic [15:0] b; } v8s_t;
typedef enum logic [31:0] { V8_A = 32'h5 } v8e_t;

module v8_v49 #(
  parameter int      W   = 32,
  parameter v8s_t    STP = '{a: 16'h1, b: 16'h2},  // packed-STRUCT probe
  parameter logic [W-1:0] N1 = 32'h1,
  parameter v8e_t    ETP = V8_A,                   // ENUM-TYPED probe
  parameter logic [W-1:0] N2 = 32'h2,
  parameter logic [W-1:0] ARR [0:1] = '{32'h3, 32'h4}, // UNPACKED-ARRAY probe
  parameter logic [W-1:0] N3 = 32'h3,
  parameter logic [W-1:0] CLG = $clog2(64),        // FUNCTION-INITIALISED probe
  parameter logic [W-1:0] N4 = 32'h4
) (
  input  logic [W-1:0] n,
  output logic [95:0]  t1, t2, t3, t4
);
  assign t1 = {STP,    N1, n};
  assign t2 = {ETP,    N2, n};
  assign t3 = {ARR[0], N3, n};
  assign t4 = {CLG,    N4, n};
endmodule
