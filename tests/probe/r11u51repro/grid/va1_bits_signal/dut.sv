// VERIFIER arm (r11v51) — ROAD A, the half of getTypespec the pass never cut:
// the PORTS-and-SIGNALS lookup at CompileExpression.cpp:4544-4557, and a type
// parameter whose default is a BUILT-IN keyword rather than a package struct.
// The map's rule predicts: an argument that names a PORT or a SIGNAL resolves
// through the second lookup and therefore FOLDS on both sides; a type
// parameter never resolves and is KEPT by golden whatever it is bound to.
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
endpackage
module dut #(
    parameter type TB = logic [9:0],         // type parameter bound to a KEYWORD
    parameter type TS = pk::req_t
) (
    input  logic [11:0] pin,                 // a PORT
    output logic o
);
  logic [13:0] sig;                          // a SIGNAL (net)
  pk::req_t     v;                           // a signal of a typedef type
  localparam int B1 = $bits(pin);            // arg = port name
  localparam int B2 = $bits(sig);            // arg = signal name
  localparam int B3 = $bits(v);              // arg = signal of struct type
  localparam int B4 = $bits(v.d);            // arg = a MEMBER of a signal
  localparam int B5 = $bits(TB);             // arg = type param bound to keyword
  localparam int B6 = $bits(TS);             // arg = type param bound to a struct
  localparam int B7 = $bits(sig);            // arg = signal name again (B7 kept for shape)
  assign o = ^{B1[0], B2[0], B3[0], B4[0], B5[0], B6[0], B7[0], sig[0], v.w, pin[0]};
endmodule
