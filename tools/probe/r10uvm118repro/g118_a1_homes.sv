// r10uvm118 arm A1 — the string-concat operand wrap in EVERY HOME.
// Each row is `{<string operand>, <implicit-string operand>, …}`; golden
// (Surelog) must show NO vpiCastOp anywhere in this file.
`define M118(S,C) {S, (C ? "item " : "sequence "), " tail"}

package a1p;

  parameter string PS = "pk";

  class c1;
    string s;
    int    i;
    // R1  class IN-BODY function
    function string inb_f(int n);
      return {s, (n > 0 ? "item " : "sequence "), " tail"};
    endfunction
    // R2  class IN-BODY task
    task inb_t(int n);
      s = {s, (n > 0 ? "item " : "sequence "), " tail"};
    endtask
    extern function string oob_f(int n);
    extern task            oob_t(int n);
    // R11 MACRO-EXPANDED span, in-body
    function string inb_macro(int n);
      return `M118(s, n > 0);
    endfunction
  endclass

  // R3  class OUT-OF-BODY function
  function string c1::oob_f(int n);
    return {s, (n > 0 ? "item " : "sequence "), " tail"};
  endfunction

  // R4  class OUT-OF-BODY TASK  (the corpus head's own home)
  task c1::oob_t(int n);
    s = {s, (n > 0 ? "item " : "sequence "), " tail"};
  endtask

  // R5  PACKAGE function
  function automatic string pkg_f(string a, int n);
    return {a, (n > 0 ? "item " : "sequence "), " tail"};
  endfunction

  // R6  PACKAGE task
  task automatic pkg_t(inout string a, input int n);
    a = {a, (n > 0 ? "item " : "sequence "), " tail"};
  endtask

  // R12 PACKAGE function, MACRO-EXPANDED span
  function automatic string pkg_macro(string a, int n);
    return `M118(a, n > 0);
  endfunction

endpackage

// R7  FREE ($unit) function
function automatic string free_f(string a, int n);
  return {a, (n > 0 ? "item " : "sequence "), " tail"};
endfunction

module a1top;
  import a1p::*;
  parameter int NB = 2;
  string ms, a;
  int    n;

  // R8  module ALWAYS_COMB
  always_comb ms = {a, (n > 0 ? "item " : "sequence "), " tail"};

  // R9  module INITIAL
  initial ms = {a, (n > 0 ? "item " : "sequence "), " tail"};

  // R10 module FINAL
  final ms = {a, (n > 0 ? "item " : "sequence "), " tail"};

  // R13 module ALWAYS_FF
  logic clk;
  always_ff @(posedge clk) ms <= {a, (n > 0 ? "item " : "sequence "), " tail"};

  // R14 module FUNCTION
  function string mod_f(int k);
    return {a, (k > 0 ? "item " : "sequence "), " tail"};
  endfunction

  // R15 module TASK
  task mod_t(int k);
    ms = {a, (k > 0 ? "item " : "sequence "), " tail"};
  endtask

  // R16 module process, MACRO-EXPANDED span
  always_comb ms = `M118(a, n > 0);

  // R17 GEN-SCOPE process
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gen_b
      string gs;
      always_comb gs = {a, (n > 0 ? "item " : "sequence "), " tail"};
      // R18 GEN-SCOPE function
      function string gen_f(int k);
        return {a, (k > 0 ? "item " : "sequence "), " tail"};
      endfunction
    end
    if (NB > 1) begin : gen_if
      string hs;
      always_comb hs = {a, (n > 0 ? "item " : "sequence "), " tail"};
    end
  endgenerate

  // R19 PARAM INIT (localparam whose init is a string concat with a ternary)
  localparam string LP = {"a", (1 ? "b" : "cc"), "d"};
  string lps;
  initial lps = LP;
endmodule
