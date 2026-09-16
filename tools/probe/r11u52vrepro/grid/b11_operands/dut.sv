// b11 — OPERAND KINDS the per-reference clone does not model.  copyRangeVec's
// cpOp models exactly three UHDM kinds (constant, ref_obj, operation) and
// DROPS any operand it cannot clone, leaving a binary operation with one
// operand.  Every bound below is legal SV and puts a fourth kind under the
// operation.
package q;
  parameter int QW = 7;
  function automatic int f(input int x); return x + 1; endfunction
endpackage

module dut #(parameter int N = 8, parameter int DEPTH = 4) (
  input logic clk,
  output logic o
);
  localparam int ARR [0:1] = '{4, 6};
  // sys_func_call operand
  typedef logic [$clog2(N)-1:0] t_sys [DEPTH];
  // sys_func_call ALONE as the bound (no enclosing operation)
  typedef logic [$clog2(N):0] t_sysbare [DEPTH];
  // $bits of a type
  typedef logic [$bits(int)-1:0] t_bits [DEPTH];
  // bit-select of a localparam array
  typedef logic [ARR[0]-1:0] t_sel [DEPTH];
  // a constant FUNCTION call from a package
  typedef logic [q::f(N)-1:0] t_fn [DEPTH];
  // a scoped package parameter under an operation
  typedef logic [q::QW-1:0] t_scp [DEPTH];
  // control
  typedef logic [N-1:0] t_par [DEPTH];

  t_sys a_sys; t_sysbare a_sysbare; t_bits a_bits; t_sel a_sel;
  t_fn a_fn;   t_scp a_scp;         t_par a_par;
  assign o = a_sys[0][0] ^ a_sysbare[0][0] ^ a_bits[0][0] ^ a_sel[0][0] ^
             a_fn[0][0] ^ a_scp[0][0] ^ a_par[0][0];
endmodule
