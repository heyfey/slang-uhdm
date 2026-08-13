// VERIFIER probe v4 — § scopedRootFromStmtSyntax1's WRONG-`::` risk.
// The lookup keys on the base's SourceLocation inside the enclosing STATEMENT.
// If two `::`-scoped chains in ONE statement could ever report the SAME
// location — which is what a macro used twice in one statement would do if
// slang mapped both expansions back to the macro DEFINITION — the walk could
// split the wrong `::`.
`define PUSHIT(q) q.push_back(1)
`define SZ(q) q.size()
package p6;
  int q6[$];
  int r6[$];
endpackage
module m6;
  int x;
  function automatic int f6();
    int y;
    // two expansions of ONE macro, same statement, DIFFERENT queues
    y = `SZ(p6::q6) + `SZ(p6::r6);
    // two expansions of ONE macro, same statement, SAME queue
    y += `SZ(p6::q6) + `SZ(p6::q6);
    // statement-position macro
    `PUSHIT(p6::q6);
    `PUSHIT(p6::r6);
    return y;
  endfunction
  initial x = f6();
endmodule
