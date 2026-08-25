// r10v133 arm E - CONSTANT-FUNCTION calls in genuinely constant contexts.
// The riskiest half of the law: if golden folds ANY of these and we now keep,
// this arm names it.  MEASUREMENT ONLY.
package pv133e;
  function automatic int cfw133(input int n);
    return n * 2;
  endfunction
  function automatic int cfz133();
    return 8;
  endfunction
  parameter int EP133 = cfz133();
endpackage

module vm133e;
  import pv133e::*;
  localparam int L1 = $bits(cfz133());          // E01 localparam over a const call
  localparam int L2 = $bits(cfw133(3));         // E02 localparam, argumented call
  localparam int L3 = $bits(EP133);             // E03 control: param, folds
  localparam int L4 = $bits(cfz133()) + 1;      // E04 inside an operation
  localparam int L5 = $bits(cfz133() + 1);      // E05 call inside the argument op
  parameter  int P1 = $bits(cfz133());          // E06 parameter (overridable)
  logic [L1-1:0] wl1;
  logic [$bits(cfz133())-1:0] wl2;              // E07 range bound
  logic [7:0] wl3 [$bits(cfz133())];            // E08 unpacked bound
  bit [$bits(cfz133())-1:0] wl4;
  typedef bit [$bits(cfz133())-1:0] tb133_t;    // E09 typedef range bound
  tb133_t tvv;
  int r;
  initial begin
    r = {$bits(cfz133()){1'b1}};                // E10 replication count
    r = wl2[$bits(cfz133())-1];                 // E11 select index
    r = wl2[$bits(cfz133())-1 -: 2];            // E12 indexed part-select
    r = int'($bits(cfz133()));                  // E13 cast operand
    r = $bits(cfz133())'(3);                    // E14 CAST SIZE
    if (r == 0) r = 1;
  end
endmodule
