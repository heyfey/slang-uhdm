// r10vbuvm29 arm B (VERIFIER) — POSITIONS a written cast over a stream can
// occupy that arm C did not reach: continuous assign, port actual, case
// expression + case item, ternary arms, for/while control, foreach body,
// system-call argument, NAMED call argument, a default formal value, an
// aggregate initialiser, and the LHS-adjacent `$cast` first argument.
module vb29_sub #(parameter int P = 0) (input int pin, output int pout);
  assign pout = pin + P;
endmodule

module vb29;
  int i1, i2;
  bit __b[];
  int arr [8];
  int w;
  bit __d[];
  function automatic int g(int x = int'({ << bit { 1'b1, 31'b0 }}));  // DEFAULT formal (width-matched)
    return x;
  endfunction
  function automatic int gn(int a, int b); return a + b; endfunction

  // continuous assign (a 4-state net type: `int` is not a legal net type)
  wire logic [31:0] cw;
  assign cw = int'({ << bit { __b }});

  // port actual
  vb29_sub u0 (.pin(int'({ << bit { __b }})), .pout(i2));

  initial begin
    // case expression AND a case item
    case (int'({ << bit { __b }}))
      int'({ << bit { __b }}): i1 = 1;
      default: i1 = 2;
    endcase
    // ternary arms
    i1 = (w != 0) ? int'({ << bit { __b }}) : int'({ >> bit { __b }});
    // for-loop init and condition
    for (int k = int'({ << bit { __b }}); k < 2; k++) i1 = k;
    // while condition
    while (int'({ << bit { __b }}) == 99) i1 = 0;
    // system-call argument
    $display("%0d", int'({ << bit { __b }}));
    // NAMED call argument
    i1 = gn(.a(int'({ << bit { __b }})), .b(1));
    // default-formal call
    i1 = g();
    // aggregate initialiser of an unpacked array
    arr = '{default: int'({ << bit { __b }})};
    // foreach body
    foreach (arr[k]) arr[k] = int'({ << bit { __b }});
  end
endmodule
