// r11u66 arm g2 — CONSTANT FUNCTION CALLS and other non-operator folds at the
// ELABORATED pattern-operand site (RV0 names "a constant function call -> INT:6
// ct7").  Packed struct, package parameter, read through a module parameter
// port so the elaborated copy flat-folds.
package q2;
  localparam int K = 6;
  function automatic int f_id(input int x);
    return x;
  endfunction
  function automatic int unsigned f_uid(input int unsigned x);
    return x;
  endfunction
  function automatic int f_neg(input int x);
    return -x;
  endfunction
  typedef struct packed {
    logic [31:0] fc;     // f_id(6)          a constant function call
    logic [31:0] fk;     // f_id(K)          the same through a name
    logic [31:0] fu;     // f_uid(6)         an UNSIGNED-returning function
    logic signed [31:0] fn;  // f_neg(6)     a function returning a negative
    logic [31:0] fa;     // f_id(6) + 1      a call UNDER an add
    logic [31:0] fs;     // f_id(6) - 1      a call UNDER a subtract
    logic [31:0] sb;     // $bits(K)         a SYSTEM call (table: UINT)
    logic [31:0] sc;     // $clog2(40)       a SYSTEM call (table: UINT)
    logic [31:0] pl;     // 7                a plain unsized literal (control)
  } c2_t;
  localparam c2_t L2 = '{fc: f_id(6), fk: f_id(K), fu: f_uid(6), fn: f_neg(6),
                         fa: f_id(6) + 1, fs: f_id(6) - 1, sb: $bits(K),
                         sc: $clog2(40), pl: 7};
endpackage
module g2_fncall66 #(parameter q2::c2_t C = q2::L2)
                   (output logic [31:0] o1, output logic [31:0] o2,
                    output logic [31:0] o3, output logic signed [31:0] o4,
                    output logic [31:0] o5, output logic [31:0] o6,
                    output logic [31:0] o7, output logic [31:0] o8,
                    output logic [31:0] o9);
  assign o1 = C.fc;  assign o2 = C.fk;  assign o3 = C.fu;
  assign o4 = C.fn;  assign o5 = C.fa;  assign o6 = C.fs;
  assign o7 = C.sb;  assign o8 = C.sc;  assign o9 = C.pl;
endmodule
