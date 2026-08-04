// r10rggen8 t4: what VALUE does Surelog put in a compound-assignment's
// literal Rhs?  t3 showed `a += 1` (a==0) -> UINT:1, `b -= 2` (b==5) -> INT:3,
// `b *= 3` (b==3) -> INT:9 — the FOLDED RESULT, not the literal.  Rggen's
// rggen_or_reducer:30 `list_index += 1` comes out UINT:0 instead, and the one
// structural difference is the IF/ELSE chain sitting between the initialiser
// and the compound assignment.  Each function below isolates one candidate.
module top #(parameter int N = 3) (output int o);
  // g1: straight-line, no branch — control (expect folded result 1).
  function automatic int g1(int n);
    int a;
    a = 0;
    while (a < n) begin
      a += 1;
    end
    return a;
  endfunction

  // g2: an if/else on a NON-constant condition before the compound assign.
  function automatic int g2(int n);
    int a;
    int c;
    a = 0;
    c = 0;
    while (a < n) begin
      if (n > 4)
        c = 1;
      else
        c = 2;
      a += 1;
    end
    return a + c;
  endfunction

  // g3: the LHS itself written under a branch before the compound assign.
  function automatic int g3(int n);
    int a;
    a = 0;
    while (a < n) begin
      if (n > 4)
        a = 1;
      a += 1;
    end
    return a;
  endfunction

  // g4: an unresolvable read (an array element indexed by the LHS) between.
  function automatic int g4(int n);
    int a;
    bit [7:0] arr[4];
    a = 0;
    arr = '{0, 1, 2, 3};
    while (a < n) begin
      arr[a] = 8'(n);
      a += 1;
    end
    return a;
  endfunction

  localparam int R1 = g1(N);
  localparam int R2 = g2(N);
  localparam int R3 = g3(N);
  localparam int R4 = g4(N);
  assign o = R1 + R2 + R3 + R4;
endmodule
