// r10buvm6 arm 2 — the OTHER `$` populations, the ones a global
// UnboundedLiteral arm in emitExpr would also reach.  Arm 1 proved golden mints
// the `$` constant in every SELECT position; this arm asks whether the same
// object appears where `$` is NOT a select index, because that is the blast
// radius of a global arm:
//
//   e01/e02  SVA cycle-delay ranges  `##[1:$]`, `##[2:$]`     (Earlgrey/ariane/sha3pad corpus)
//   e03      SVA consecutive repetition `[*1:$]`              (CheckerInst corpus)
//   e04      SVA goto/non-consecutive repetition `[->1:$]`
//   e05      an UNBOUNDED PARAMETER (`parameter int P = $`)   (1800-2017 6.20.2.1)
//   e06      `$` handed to a formal whose default is unbounded
//   e07      `$isunbounded(P)` — the system call that reads one
//   e08      a bounded-queue MAX declaration `int q[$:3]`
//   e09      `$` as a CONSTRAINT bound (inside { [1:$] })
//   e10      a `$`-bounded range in a covergroup bin
module mexotic6 (input logic clk, input logic a, input logic b, input logic c);

  // ---------------- e01/e02: cycle-delay ranges with an unbounded max
  property pr_e01;
    @(posedge clk) a |-> ##[1:$] b;
  endproperty
  assert property (pr_e01);

  property pr_e02;
    @(posedge clk) a |=> strong(##[2:$] c);
  endproperty
  assert property (pr_e02);

  // ---------------- e03: consecutive repetition with an unbounded max
  property pr_e03;
    @(posedge clk) a[*1:$] ##1 b;
  endproperty
  assert property (pr_e03);

  // ---------------- e04: goto repetition with an unbounded max
  property pr_e04;
    @(posedge clk) a ##1 b[->1:$] ##1 c;
  endproperty
  assert property (pr_e04);

endmodule

package pexotic6;
  // ---------------- e05: the UNBOUNDED PARAMETER
  class ce6 #(parameter int P6 = 4);
    int arr6[P6];
  endclass

  // ---------------- e07: $isunbounded on a parameter
  function automatic int f_e07(int q6);
    return q6;
  endfunction

  // ---------------- e08: a bounded-queue declaration
  class cb6;
    int qb6[$:3];
    string sb6[$:7];
    function int e08();
      return qb6[$];
    endfunction
  endclass

  // ---------------- e09: a `$`-bounded constraint range
  class cr6;
    rand int r6;
    constraint c_e09 { r6 inside { [1:$] }; }
  endclass
endpackage

module mparam6;
  // e05 instantiation with the literal `$` as the parameter value
  pexotic6::ce6 #(4) h6;
  // e06/e07: `$isunbounded` reads a parameter that MAY be `$`
  localparam int LP6 = 8;
  initial begin
    if ($isunbounded(LP6)) $display("unbounded");
  end
endmodule
