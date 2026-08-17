// r10rgg2 a1 — THE EVALUATION COUNTER.
//
// Every cell uses the same counter body:
//     int a;  a = 1;  a += 1;  return a + n;
// The `a = 1` literal is a DIFFERENT object from the `+= 1` literal, and a
// plain assign never takes an op arm, so `a`'s value object at the compound
// assign is always the init literal (value 1).  Therefore each EVALUATION of
// the function does exactly  L := L + 1  on the `+= 1` literal, and after E
// evaluations that literal reads  1 + E.  The literal's own value IS the
// evaluation count.  One cell per question about the schedule.
//
// c1  module instantiated ONCE
// c2  module instantiated TWICE (same parametrization)
// c3  module instantiated TWICE with DIFFERENT parametrizations
// c4  module NEVER instantiated
// c5  TWO localparams in one module both call f, one instance
// c6  the localparam is read MANY times (does a read re-evaluate?)
// c7  module inside a generate-for with 3 iterations
// c8  instance ARRAY of 3
// c9  function in a PACKAGE, called from a package localparam
module c1_m #(parameter int N = 1) (output int o);
  function automatic int f(int n);
    int a;
    a = 1;
    a += 1;
    return a + n;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module c2_m #(parameter int N = 1) (output int o);
  function automatic int f(int n);
    int a;
    a = 1;
    a += 1;
    return a + n;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module c3_m #(parameter int N = 1) (output int o);
  function automatic int f(int n);
    int a;
    a = 1;
    a += 1;
    return a + n;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module c4_m #(parameter int N = 1) (output int o);
  function automatic int f(int n);
    int a;
    a = 1;
    a += 1;
    return a + n;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module c5_m #(parameter int N = 1) (output int o);
  function automatic int f(int n);
    int a;
    a = 1;
    a += 1;
    return a + n;
  endfunction
  localparam int P1 = f(N);
  localparam int P2 = f(N + 1);
  assign o = P1 + P2;
endmodule

module c6_m #(parameter int N = 1) (output int o);
  function automatic int f(int n);
    int a;
    a = 1;
    a += 1;
    return a + n;
  endfunction
  localparam int P = f(N);
  logic [P-1:0] v1;
  logic [P-1:0] v2;
  logic [P-1:0] v3;
  assign o = P + P + P + P + int'(v1[0]) + int'(v2[0]) + int'(v3[0]);
endmodule

module c7_m #(parameter int N = 1) (output int o);
  function automatic int f(int n);
    int a;
    a = 1;
    a += 1;
    return a + n;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

module c8_m #(parameter int N = 1) (output int o);
  function automatic int f(int n);
    int a;
    a = 1;
    a += 1;
    return a + n;
  endfunction
  localparam int P = f(N);
  assign o = P;
endmodule

package c9_p;
  function automatic int f(int n);
    int a;
    a = 1;
    a += 1;
    return a + n;
  endfunction
  localparam int PP = f(3);
endpackage

module a1_rgg2 (output int o);
  int w1, w2a, w2b, w3a, w3b, w5, w6, w8a, w8b, w8c;
  int w7 [0:2];
  c1_m #(.N(5)) u1  (.o(w1));
  c2_m #(.N(5)) u2a (.o(w2a));
  c2_m #(.N(5)) u2b (.o(w2b));
  c3_m #(.N(5)) u3a (.o(w3a));
  c3_m #(.N(6)) u3b (.o(w3b));
  c5_m #(.N(5)) u5  (.o(w5));
  c6_m #(.N(5)) u6  (.o(w6));
  for (genvar g = 0; g < 3; g++) begin : gg
    c7_m #(.N(5)) u7 (.o(w7[g]));
  end
  c8_m #(.N(5)) u8 [0:2] (.o({w8a, w8b, w8c}));
  assign o = w1 + w2a + w2b + w3a + w3b + w5 + w6 + w7[0] + w7[1] + w7[2]
           + w8a + w8b + w8c + c9_p::PP;
endmodule
