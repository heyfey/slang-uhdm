// VERIFIER CELL e02 - an UNKNOWN module instance makes its own scope
// uninstantiated; a `::` reference inside the instantiating module's
// unresolved-def region is silent too.
module top59e02;
  int i;
  nosuchmod59 u0 (.a(i));
  initial begin
    i = 1;
  end
endmodule
