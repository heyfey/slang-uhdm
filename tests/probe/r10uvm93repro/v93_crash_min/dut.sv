// v93 VERIFIER crash repro — `{ << real { q }} = f;` with -elabuhdm.
// pristine b1a0447: rc=0.  r10uvm93 as SHIPPED: SIGSEGV (rc=139) in
// UHDM::ExprEval::reduceExpr <- UhdmAdjuster::updateParentWithReducedExpression
// <- listenSys_func_call, which dereferences Tf_call_args() unconditionally.
// Fixed by giving the emitted $bits call an EMPTY (non-null) arg vector.
module m1;
  byte q[];
  bit [63:0] f;
  initial begin
    { << real { q }} = f;
  end
endmodule
