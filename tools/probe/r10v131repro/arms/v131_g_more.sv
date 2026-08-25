// v131 arm G — more homes and control shapes.
interface Igate;
  int iv;
  task automatic itask();
    fork : ifNamed iv = 1; join_none : ifNamed
    fork iv = 2; join_any
    fork : ifEmpty join : ifEmpty
  endtask
endinterface

module Gmod;
  int g1, g2, g3;
  // fork as the DIRECT statement of initial (no begin)
  initial fork : direct1 g1 = 1; join_none : direct1
  initial fork g2 = 2; join_any
  initial fork : directEmpty join_none : directEmpty
  // fork as the direct statement of always_comb / always_ff / final
  final begin
    fork : finFork g3 = 3; join_none : finFork
    fork : finEmpty join_none : finEmpty
  end
  always_ff @(posedge g2) begin
    fork : affFork g3 = 5; join_none : affFork
  end
  // fork in while / repeat / do-while / forever
  initial begin
    int w = 0;
    while (w < 2) begin
      fork : whFork w = w + 1; join_none : whFork
    end
    repeat (2) begin
      fork : rpFork g1 = 6; join_any : rpFork
      fork : rpEmpty join : rpEmpty
    end
    do begin
      fork g2 = 7; join_none
    end while (0);
    // fork inside a case item
    case (g1)
      6: fork : caseFork g3 = 8; join_none : caseFork
      default: fork : caseEmpty join_any : caseEmpty
    endcase
    // fork with only an EMPTY begin inside
    fork : hasEmptyBegin begin end join_none : hasEmptyBegin
    fork begin end join_any
    // nested empty fork as the sole child
    fork : outerOnlyEmpty fork : innerNil join_any : innerNil join_none : outerOnlyEmpty
    // fork with delays
    fork : delFork #1 g1 = 9; #2 g2 = 10; join : delFork
  end
  // fork inside a generate block
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gblk
      initial begin
        fork : genFork g1 = gi; join_none : genFork
        fork : genEmpty join : genEmpty
      end
    end
  endgenerate
endmodule
