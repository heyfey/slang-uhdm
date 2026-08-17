// r10rgg2 b1 — the PER-EVALUATION iteration model, the operator arms, and the
// LHS/RHS shape gates.  Every cell's module is instantiated EXACTLY ONCE with
// EXACTLY ONE constant-evaluated call site, so E = 1 and the literal's value
// isolates the within-evaluation schedule.
//
// MODEL under test (L = the literal object, v = the accumulator's value read
// at the first execution, I = executions of the statement in one evaluation):
//     +=  : L := (L + v) then DOUBLES (I-1) times, uint64 wrap
//     -=  : L := (v - L), then 0 from the second execution on
//     *=  : L := (v * L), then SQUARES
//     /=  : L := (v / L), then 1 from the second execution on
//     other ops (%=, &=, <<=) : NO arm in setValueInInstance -> UNTOUCHED
//     a SELECT LHS (p[0] += 1) : the arm REBUILDS c -> literal UNTOUCHED
//     a non-constant RHS (a += (1+1), a += K) : c is a FRESH reduce product
//                                              -> the written literals UNTOUCHED

module d1_m #(parameter int N = 1) (output int o);      // I = 1
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i) a += 1;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module d2_m #(parameter int N = 1) (output int o);      // I = 2 -> 2
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i) a += 1;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module d3_m #(parameter int N = 1) (output int o);      // I = 3 -> 4
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i) a += 1;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module d5_m #(parameter int N = 1) (output int o);      // I = 5 -> 16
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i) a += 1;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module d20_m #(parameter int N = 1) (output int o);     // I = 20 -> 524288
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i) a += 1;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module d64_m #(parameter int N = 1) (output int o);     // I = 64 -> 2^63
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i) a += 1;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module d65_m #(parameter int N = 1) (output int o);     // I = 65 -> 0 (wrap)
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i) a += 1;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module dw_m #(parameter int N = 1) (output int o);      // WHILE, I = 3 -> 4
  function automatic int f(int n);
    int a;
    a = 0;
    while (a < n) begin
      a += 1;
    end
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module dnest_m #(parameter int N = 1) (output int o);   // NESTED, I = 6 -> 32
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i)
      for (int j = 0; j < 2; ++j)
        a += 1;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module dsub1_m #(parameter int N = 1) (output int o);   // -= once -> 0-2 = -2
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i) a -= 2;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module dsub3_m #(parameter int N = 1) (output int o);   // -= 3x -> 0
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i) a -= 2;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module dmul1_m #(parameter int N = 1) (output int o);   // *= once -> 3*2 = 6
  function automatic int f(int n);
    int a;
    a = 3;
    for (int i = 0; i < n; ++i) a *= 2;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module dmul2_m #(parameter int N = 1) (output int o);   // *= 2x -> 36
  function automatic int f(int n);
    int a;
    a = 3;
    for (int i = 0; i < n; ++i) a *= 2;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module ddiv2_m #(parameter int N = 1) (output int o);   // /= 2x -> 1
  function automatic int f(int n);
    int a;
    a = 100;
    for (int i = 0; i < n; ++i) a /= 2;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module dmod_m #(parameter int N = 1) (output int o);    // %= : NO arm
  function automatic int f(int n);
    int a;
    a = 7;
    for (int i = 0; i < n; ++i) a %= 2;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module dshl_m #(parameter int N = 1) (output int o);    // <<= : NO arm
  function automatic int f(int n);
    int a;
    a = 7;
    for (int i = 0; i < n; ++i) a <<= 1;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module dparam_m #(parameter int N = 1) (output int o);  // RHS is a localparam
  localparam int K = 3;
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i) a += K;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module dexpr_m #(parameter int N = 1) (output int o);   // RHS is an operation
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i) a += (1 + 1);
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module dsel_m #(parameter int N = 1) (output int o);    // SELECT LHS
  function automatic int f(int n);
    bit [3:0][7:0] p;
    p = '0;
    for (int i = 0; i < n; ++i) p[0] += 1;
    return int'(p[0]);
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module dtwo_m #(parameter int N = 1) (output int o);    // TWO literals, one var
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i) begin
      a += 1;
      a += 3;
    end
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module dif_m #(parameter int N = 1) (output int o);     // guarded OFF -> I = 0
  function automatic int f(int n);
    int a;
    a = 0;
    if (n > 100) a += 1;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module dsized_m #(parameter int N = 1) (output int o);  // SIZED literal 4'd1
  function automatic int f(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i) a += 4'd1;
    return a;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module b1_rgg2 (output int o);
  int q1, q2, q3, q5, q20, q64, q65, qw, qn;
  int qs1, qs3, qm1, qm2, qd2, qmod, qshl, qpar, qexp, qsel, qtwo, qif, qsz;
  d1_m    #(.N(1))  u1   (.o(q1));
  d2_m    #(.N(2))  u2   (.o(q2));
  d3_m    #(.N(3))  u3   (.o(q3));
  d5_m    #(.N(5))  u5   (.o(q5));
  d20_m   #(.N(20)) u20  (.o(q20));
  d64_m   #(.N(64)) u64  (.o(q64));
  d65_m   #(.N(65)) u65  (.o(q65));
  dw_m    #(.N(3))  uw   (.o(qw));
  dnest_m #(.N(3))  un   (.o(qn));
  dsub1_m #(.N(1))  us1  (.o(qs1));
  dsub3_m #(.N(3))  us3  (.o(qs3));
  dmul1_m #(.N(1))  um1  (.o(qm1));
  dmul2_m #(.N(2))  um2  (.o(qm2));
  ddiv2_m #(.N(2))  ud2  (.o(qd2));
  dmod_m  #(.N(3))  umod (.o(qmod));
  dshl_m  #(.N(3))  ushl (.o(qshl));
  dparam_m #(.N(3)) upar (.o(qpar));
  dexpr_m #(.N(3))  uexp (.o(qexp));
  dsel_m  #(.N(3))  usel (.o(qsel));
  dtwo_m  #(.N(3))  utwo (.o(qtwo));
  dif_m   #(.N(3))  uif  (.o(qif));
  dsized_m #(.N(3)) usz  (.o(qsz));
  assign o = q1+q2+q3+q5+q20+q64+q65+qw+qn+qs1+qs3+qm1+qm2+qd2+qmod+qshl
           + qpar+qexp+qsel+qtwo+qif+qsz;
endmodule
