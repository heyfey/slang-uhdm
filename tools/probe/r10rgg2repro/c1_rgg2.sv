// r10rgg2 c1 — (A) the WRAP WIDTH of the write-back arithmetic and (B) the rest
// of the evaluation-count schedule.
//
// (A) mask cells use the loop form (E = 1, I = the loop count) and ask which
//     width the running uint64 is truncated to: the ACCUMULATOR's, the
//     PARAMETER's, or a fixed 32/64.
// (B) schedule cells use the a1 counter form (a = 1; a += 1) whose literal
//     reads 1 + E, so the value IS the evaluation count.

// ---- (A) wrap width -------------------------------------------------------
module e32_m #(parameter int N = 1) (output int o);      // int acc, I = 32
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i) a += 1;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module e33_m #(parameter int N = 1) (output int o);      // int acc, I = 33
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i) a += 1;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module e64_m #(parameter int N = 1) (output longint o);  // longint acc, I = 64
  function automatic longint f(int n);
    longint a;
    a = 0;
    for (int i = 0; i < n; ++i) a += 1;
    return a;
  endfunction
  localparam longint P = f(N);
  assign o = P;
endmodule

module e17_m #(parameter int N = 1) (output shortint o); // shortint acc, I = 17
  function automatic shortint f(int n);
    shortint a;
    a = 0;
    for (int i = 0; i < n; ++i) a += 1;
    return a;
  endfunction
  localparam shortint P = f(N);
  assign o = P;
endmodule

module e9_m #(parameter int N = 1) (output logic [7:0] o); // bit[7:0], I = 9
  function automatic bit [7:0] f(int n);
    bit [7:0] a;
    a = 0;
    for (int i = 0; i < n; ++i) a += 1;
    return a;
  endfunction
  localparam bit [7:0] P = f(N);
  assign o = P;
endmodule

module ew_m #(parameter int N = 1) (output logic [99:0] o); // int acc, 100b par
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i) a += 1;
    return a;
  endfunction
  localparam logic [99:0] P = f(N);
  assign o = P;
endmodule

module el_m #(parameter int N = 1) (output longint o);   // int acc, longint par
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i) a += 1;
    return a;
  endfunction
  localparam longint P = f(N);
  assign o = P;
endmodule

// ---- (B) schedule ---------------------------------------------------------
module g1_inner (output int o);                          // nested one deep
  function automatic int f(int n);
    int a;
    a = 1;
    a += 1;
    return a + n;
  endfunction
  localparam int P = f(2);
  assign o = P;
endmodule
module g1_m (output int o);
  g1_inner ui (.o(o));
endmodule

module g2_m #(parameter int N = 1) (output int o);        // UNTAKEN gen branch
  function automatic int f(int n);
    int a;
    a = 1;
    a += 1;
    return a + n;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module g3_m #(parameter int N = 1) (output int o);        // NESTED const call
  function automatic int inner(int n);
    int a;
    a = 1;
    a += 1;
    return a + n;
  endfunction
  function automatic int outer(int n);
    return inner(n) + inner(n + 1);
  endfunction
  localparam int P = outer(N);
  assign o = P;
endmodule

module g4_m #(parameter int N = 1) (output int o);        // localparam in a gen
  function automatic int f(int n);
    int a;
    a = 1;
    a += 1;
    return a + n;
  endfunction
  if (1) begin : gb
    localparam int P = f(N);
    assign o = P;
  end
endmodule

interface g5_if #(parameter int N = 1) ();               // INTERFACE
  function automatic int f(int n);
    int a;
    a = 1;
    a += 1;
    return a + n;
  endfunction
  localparam int P = f(N);
endinterface

module g6_m #(parameter int N = 1) (output int o);        // const AND non-const
  function automatic int f(int n);
    int a;
    a = 1;
    a += 1;
    return a + n;
  endfunction
  localparam int P = f(N);
  int r;
  always_comb r = f(N + 1);
  assign o = P + r;
endmodule

module g7_m #(parameter int N = 1, parameter int Q = 0) (output int o);
  function automatic int f(int n);                        // PARAMETER default
    int a;
    a = 1;
    a += 1;
    return a + n;
  endfunction
  localparam int P = Q;
  assign o = P;
endmodule

module g8_m #(parameter int N = 1) (output int o);        // FIVE instances
  function automatic int f(int n);
    int a;
    a = 1;
    a += 1;
    return a + n;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module c1_rgg2 (output int o);
  int r32, r33, rw, rl, r1, r3, r4, r6, r7;
  longint r64, r64b;
  shortint r17;
  logic [7:0] r9;
  logic [99:0] r100;
  int r8 [0:4];
  e32_m #(.N(32)) u32 (.o(r32));
  e33_m #(.N(33)) u33 (.o(r33));
  e64_m #(.N(64)) u64 (.o(r64));
  e17_m #(.N(17)) u17 (.o(r17));
  e9_m  #(.N(9))  u9  (.o(r9));
  ew_m  #(.N(33)) uw  (.o(r100));
  el_m  #(.N(33)) ul  (.o(r64b));
  g1_m            ug1 (.o(r1));
  if (0) begin : off
    g2_m #(.N(5)) ug2 (.o(rw));
  end
  g3_m #(.N(5))   ug3 (.o(r3));
  g4_m #(.N(5))   ug4 (.o(r4));
  g5_if #(.N(5))  ug5 ();
  g6_m #(.N(5))   ug6 (.o(r6));
  g7_m #(.N(5), .Q(9)) ug7 (.o(r7));
  for (genvar k = 0; k < 5; k++) begin : g8
    g8_m #(.N(5)) ug8 (.o(r8[k]));
  end
  assign o = r32 + r33 + int'(r64) + int'(r17) + int'(r9) + int'(r100)
           + int'(r64b) + r1 + r3 + r4 + ug5.P + r6 + r7
           + r8[0] + r8[1] + r8[2] + r8[3] + r8[4];
endmodule
