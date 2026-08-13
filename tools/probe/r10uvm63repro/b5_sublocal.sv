// r10uvm63 arm b5 — VERIFIER-ADDED.  SUBROUTINE-LOCAL and FORMAL-ARGUMENT
// associative indices: the axis arms b1..b4 never reached.
//
// WHY THIS ARM EXISTS.  § assocIndexTsSigned63 is stamped inside
// `assocIndexTs` (src/UhdmExporter.cpp), and `assocIndexTs` has FIVE callers,
// two of which live in src/TaskFuncEmit.cpp (lines 1280 and 2232) — the
// SUBROUTINE-LOCAL variable writer and the FORMAL-ARGUMENT writer.  Arms
// b1 (class property), b2 (module variable), b3 (named/multi-dim) and
// b4 (package / interface / typedef container) do not contain a single
// function-local or task-local associative array, so those two call sites
// received the new stamp WITHOUT a golden measurement behind them.
//
// WHY THAT IS THE AXIS TO PICK, and not an arbitrary extra cell:
// src/UhdmExporter.cpp's § arrayVarSignedWritten8 comment states, as a
// MEASURED result, that the sibling signedness law INVERTS at exactly this
// scope —
//     "IT IS THE OPPOSITE AT SUBROUTINE/BLOCK-LOCAL SCOPE — arm a9 cells
//      n01/n02/n03 show golden putting `vpiSigned:1` on the ELEMENT and
//      nothing on the array_var there — which is why this law is scope-bound
//      and TaskFuncEmit.cpp's `reg0->VpiSigned(true)` sites are deliberately
//      left alone."
// So subroutine scope is the one axis in this file where a signedness law is
// already known to flip.  A law claiming "no scope term" must be measured
// there or the claim is unsupported on its most dangerous cell.
//
// Names mirror b1's c<NN>_ / b2's m<NN>_ ordering where the kinds coincide:
//   s<NN>_  function-local variable        (TaskFuncEmit local writer)
//   t<NN>_  task-local variable            (same writer, task view)
//   a<NN>_  FORMAL ARGUMENT of a function  (TaskFuncEmit formal writer)
//   k<NN>_  CLASS-METHOD-local variable    (subroutine scope inside a class)

function automatic int f_locals();
  int s01_integer[integer];
  int s02_int[int];
  int s03_byte[byte];
  int s04_shortint[shortint];
  int s05_longint[longint];
  int s06_time[time];
  int s07_intu[int unsigned];
  int s08_bit[bit];
  int s09_string[string];
  int s10_md_si[string][integer];
  s01_integer[1] = 1;
  return s01_integer[1];
endfunction

task automatic t_locals();
  int t01_integer[integer];
  int t02_int[int];
  int t03_byte[byte];
  int t06_time[time];
  int t07_intu[int unsigned];
  int t08_bit[bit];
  int t09_string[string];
  t01_integer[2] = 2;
endtask

// FORMAL ARGUMENTS carrying an associative index — the second TaskFuncEmit
// call site (line 2232), reached through the argument writer rather than the
// local-variable writer.
function automatic int f_args(input int a01_integer[integer],
                              input int a02_int[int],
                              input int a03_byte[byte],
                              input int a06_time[time],
                              input int a07_intu[int unsigned],
                              input int a08_bit[bit],
                              input int a09_string[string]);
  return a01_integer[0];
endfunction

class b5c;
  function automatic int m_locals();
    int k01_integer[integer];
    int k02_int[int];
    int k03_byte[byte];
    int k06_time[time];
    int k07_intu[int unsigned];
    int k08_bit[bit];
    int k09_string[string];
    k01_integer[3] = 3;
    return k01_integer[3];
  endfunction
endclass

module b5_top;
  int r;
  int w01_integer[integer];
  // Actuals must MATCH each formal's index type exactly: slang type-checks the
  // associative index where Surelog does not, so a single `w01_integer` passed
  // to all seven formals is a slang ERROR (measured) and would have produced no
  // RHS database at all.
  int w02_int[int];
  int w03_byte[byte];
  int w06_time[time];
  int w07_intu[int unsigned];
  int w08_bit[bit];
  int w09_string[string];
  b5c h;
  initial begin
    h = new();
    r = f_locals();
    t_locals();
    r = f_args(w01_integer, w02_int, w03_byte, w06_time,
               w07_intu, w08_bit, w09_string);
    r = h.m_locals();
  end
endmodule
