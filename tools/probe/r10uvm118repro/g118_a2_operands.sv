// r10uvm118 arm A2 — WHICH OPERAND KINDS slang wraps, and the WRITTEN-cast
// negative controls.  Golden must carry a vpiCastOp on the WRITTEN rows and on
// NOTHING else.
package a2p;
  parameter        PP  = "pp";      // implicitly-typed string parameter
  parameter string PS  = "ps";
  localparam       LPX = "lp";
endpackage

module a2top;
  import a2p::*;
  string s, r;
  int    n;
  bit [7:0] v;
  logic [15:0] w;

  // ---- rows slang WRAPS (this law drops the wrap) ----------------------
  // O1 ternary of two string literals             (the corpus head shape)
  always_comb r = {s, (n > 0 ? "item " : "sequence "), "x"};
  // O2 ternary of two string literals of the SAME width
  always_comb r = {s, (n > 0 ? "aa" : "bb"), "x"};
  // O3 ternary with an EMPTY-string arm           (uvm_phase / uvm_reg_model)
  always_comb r = {s, (n > 0 ? "" : ", "), "x"};
  // O4 NESTED ternary
  always_comb r = {s, (n > 0 ? "a" : (n < 0 ? "bb" : "ccc")), "x"};
  // O5 inner CONCATENATION of string literals
  always_comb r = {s, {"a", "bb"}, "x"};
  // O6 REPLICATION of a string literal
  always_comb r = {s, {3{"ab"}}, "x"};
  // O7 a plain string LITERAL   (already dropped before this pass — control)
  always_comb r = {s, "lit ", "x"};
  // O8 an implicitly-typed package parameter whose value is a string literal
  always_comb r = {s, PP, "x"};
  // O9 a ternary INSIDE a nested concat inside the string concat
  always_comb r = {s, {"p", (n > 0 ? "q" : "rr")}, "x"};
  // O10 the string concat as a CALL ARGUMENT (not an assignment RHS)
  initial $display({s, (n > 0 ? "item " : "sequence "), "x"});

  // ---- WRITTEN casts: golden KEEPS the cast op -------------------------
  // W1 string'(...) inside the string concat
  always_comb r = {s, string'(v), "x"};
  // W2 string'(...) of a ternary inside the string concat
  always_comb r = {s, string'((n > 0 ? 8'd1 : 8'd2)), "x"};
  // W3 string'(...) OUTSIDE any concat
  always_comb r = string'(v);
  // W4 int'(...) in a NON-string concat (a different typespec family)
  always_comb w = {v, int'(n[7:0])};
  // W5 8'(...) size cast in a non-string concat
  always_comb w = {v, 8'(n)};

  // ---- non-string concat negative controls -----------------------------
  // N1 a plain integral concat with a ternary operand: NO cast in either DB
  always_comb w = {v, (n > 0 ? 8'd1 : 8'd2)};
  // N2 a replication in a plain integral concat
  always_comb w = {v, {2{4'hA}}};
endmodule
