// v125 arm V8 — the CONTEXT the call sits in, and the same variable written by
// an output arg then read immediately.
package Ctx_Pkg;
  typedef logic [63:0] Big;
  logic [63:0] pkgVar;
  function automatic int take(output Big d); d = 64'd1; return 0; endfunction
  function automatic int feed(input  Big d); return int'(d); endfunction
endpackage

module Ctx_Top;
  import Ctx_Pkg::*;
  logic [31:0] w32;
  logic [31:0] arr32 [0:3];
  int          rc;
  bit          ok;

  initial begin
    ok  = 1;
    ok &= take(w32);                 // compound-assign statement (the UVM shape)
    rc  = feed(w32);                 // <-- READ on the next line
    if (!take(w32)) rc = 1;          // inside an if condition
    while (take(w32) == 0) break;    // inside a while condition
    case (take(w32)) 0: rc = 2; default: rc = 3; endcase
    rc = take(w32) + feed(w32);      // both operands of a binary op
    rc = feed(w32) + take(w32);
    void'(take(w32));                // void'() statement
    rc = take(arr32[2]);             // element actual
    rc = take(Ctx_Pkg::pkgVar);      // package-qualified actual (matching type)
    fork rc = take(w32); join_none   // inside a fork
    for (int q = 0; q < 2; q++) rc = take(arr32[q]);
    rc = feed(w32);
  end
endmodule
