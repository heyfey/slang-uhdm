// r10v173 arm R — WHERE THE CALL SITS.  return expressions, actual arguments,
// concatenations, replications, bit/part selects, array indices, foreach loop
// bodies, ternaries, case items and initializers — every one inside the
// package's DEF listing, in both spellings.
package tallowPkg;

  localparam int SPAN = 4;

  function automatic int unsigned pip(int unsigned n);
    return n + 1;
  endfunction

  function automatic int unsigned wax(int unsigned n);
    return n + 2;
  endfunction

  // 1. return expression, bare and qualified
  function automatic int unsigned inReturnBare(int unsigned n);
    return pip(n);
  endfunction
  function automatic int unsigned inReturnQual(int unsigned n);
    return tallowPkg::pip(n);
  endfunction

  // 2. nested as an ACTUAL of another call
  function automatic int unsigned inArg(int unsigned n);
    return wax(pip(n)) + tallowPkg::wax(tallowPkg::pip(n)) + wax(tallowPkg::pip(n));
  endfunction

  // 3. concatenation and replication (a call result cannot be selected
  //    directly in SV, so each call lands in a local first)
  function automatic logic [31:0] inConcat(int unsigned n);
    logic [31:0] c1, c2, c3;
    c1 = pip(n); c2 = tallowPkg::pip(n); c3 = wax(n);
    return {c1[7:0], c2[7:0], {2{c3[7:0]}}};
  endfunction

  // 4. bit select / part select on a local fed by a call
  function automatic logic inSelect(int unsigned n);
    logic [31:0] d1, d2;
    d1 = pip(n); d2 = tallowPkg::wax(n);
    return d1[0] ^ d2[1];
  endfunction

  // 5. as an ARRAY INDEX
  function automatic int unsigned inIndex(int unsigned n);
    int unsigned tab [0:7];
    for (int unsigned i = 0; i < 8; i++) tab[i] = i * 3;
    return tab[pip(n) % 8] + tab[tallowPkg::wax(n) % 8];
  endfunction

  // 6. inside a foreach body
  function automatic int unsigned inForeach(int unsigned n);
    int unsigned bag [SPAN];
    int unsigned acc;
    acc = 0;
    foreach (bag[j])
      acc = acc + pip(j) + tallowPkg::wax(j);
    return acc + n;
  endfunction

  // 7. ternary + case item
  function automatic int unsigned inChoice(int unsigned n);
    int unsigned r;
    r = (n > 3) ? pip(n) : tallowPkg::pip(n);
    case (n)
      0: r = r + wax(n);
      1: r = r + tallowPkg::wax(n);
      default: r = r + 1;
    endcase
    return r;
  endfunction

  // 8. a package-scope VARIABLE initializer (a call in a non-subroutine home)
  int unsigned seedVal = pip(2);
  int unsigned seedQualVal = tallowPkg::wax(3);

endpackage

module tallow_top (output int unsigned t1, output int unsigned t2, output int unsigned t3);
  import tallowPkg::*;
  assign t1 = inReturnBare(5) + inReturnQual(6) + inArg(7);
  assign t2 = inIndex(2) + inForeach(1) + inChoice(4);
  assign t3 = int'(inConcat(3)) + int'(inSelect(1)) + seedVal + seedQualVal;
endmodule
