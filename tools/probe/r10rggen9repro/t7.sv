// r10rggen9 t7: the compound-assignment WRITE-BACK, decoded from UHDM
// templates/ExprEval.cpp (setValueInInstance ~5021 + the opType tail ~5395).
//
//   assignment stmt -> rhsexp = reduceExpr(st->Rhs())        [the tree object]
//                   -> setValueInInstance(lhs, lhsexp, rhsexp, .., opType)
//        valUI  = get_uvalue(rhsexp)                 // read BEFORE any write
//        c      = any_cast<constant*>(rhsexp)        // === the tree's literal
//        prevRhs= the param_assign currently holding the LHS's value
//        vpiAddOp : c->VpiValue("UINT:" + (valUI + get_uvalue(prevRhs)))
//        vpiSubOp : c->VpiValue("INT:"  + (get_value(prevRhs) - valI))
//        vpiMultOp: c->VpiValue("INT:"  + (get_value(prevRhs) * valI))
//        vpiDivOp : c->VpiValue("INT:"  + (get_value(prevRhs) / valI))
//        ...then param_assigns gets a NEW pa whose Rhs IS c.
//
// Two consequences, both load-bearing:
//  (1) the LHS variable's stored value object IS the literal, so from the
//      second execution on prevRhs == rhsexp and `a += <lit>` DOUBLES the
//      literal every iteration (L, 2L, 4L, ...);
//  (2) the arithmetic is uint64, so a long enough loop wraps the literal to
//      ZERO — which is exactly rggen_or_reducer:30 `list_index += 1` coming
//      out UINT:0 in golden while the written literal is 1.
//
// PREDICTIONS (m = executions of the statement, L0 = the written literal):
//   w3   `a += 1` under `while (a < 3)`      -> m=3  -> L = 1*2^2  = 4
//   f5   `a += 1` under `for i in 0..4`      -> m=5  -> L = 1*2^4  = 16
//   f70  `a += 1` under `for i in 0..69`     -> m=70 -> 2^69 % 2^64 = 0
//   f64  `a += 1` under `for i in 0..63`     -> m=64 -> 2^63 = 9223372036854775808
//   s2   `b -= 2` twice (b=5)                -> INT:3 then INT:(3-3)=0  -> 0
module top (output int o);
  function automatic int w3(int n);
    int a;
    a = 0;
    while (a < n) begin
      a += 1;
    end
    return a;
  endfunction

  function automatic int f5(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i)
      a += 1;
    return a;
  endfunction

  function automatic int f70(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i)
      a += 1;
    return a;
  endfunction

  function automatic int f64(int n);
    int a;
    a = 0;
    for (int i = 0; i < n; ++i)
      a += 1;
    return a;
  endfunction

  function automatic int s2(int n);
    int b;
    b = 5;
    for (int i = 0; i < n; ++i)
      b -= 2;
    return b;
  endfunction

  localparam int R1 = w3(3);
  localparam int R2 = f5(5);
  localparam int R3 = f70(70);
  localparam int R4 = f64(64);
  localparam int R5 = s2(2);
  assign o = R1 + R2 + R3 + R4 + R5;
endmodule
