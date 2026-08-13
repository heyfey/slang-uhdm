// r10svs12 arm d3 — THE HIGHCONN REF SHAPE per connection style and actual
// form, on an interface ARRAY.
//
// The head's SECOND difference is one level below the port: the HighConn
// ref_obj's vpiFullName.  Golden scopes it through the ARRAY ALONE
// (`work@top.output_intf.Clock`); we interpose the FORMAL
// (`work@top.output_intf.clock.Clock`).  CORRECTED AT INTEGRATION: this file
// first claimed ref_obj::Compare compares VpiFullName.  IT DOES NOT — read the
// generated field list (UHDM/build/generated/src/ref_obj.cpp): VpiType,
// VpiName, VpiDefName, VpiDecompile, VpiSize, VpiGeneric, VpiStructMember,
// Typespec, Actual_group — and NO VpiFullName, NO source span.  So this
// difference is DUMP-ONLY: the port's vpiName was the whole compared head, and
// the fullname/span cells below are byte-cosmetics measured for their own sake.
//
// This arm varies the ACTUAL's form under BOTH styles, because the producer has
// a separate select-syntax branch (`emitSyntaxExpr` with a rewritten
// syntaxRefPrefix) that only fires for a NAMED connection with a select actual
// and only on a MODULE array — an interface array (`ifaceArr`) is excluded from
// it, and a POSITIONAL connection has no `NamedPortConnectionSyntax` to read.
// Cells k5/k6 pin that boundary so the fix cannot silently reroute it.
interface if1(input bit clk);
  logic sig;
  modport MP(input clk, output sig);
endinterface

module top();

bit Clock;
bit [3:0] Vec;

// k1  POSITIONAL, bare net actual                <- the witness
if1 d1[4](Clock);
// k2  NAMED, bare net actual
if1 d2[4](.clk(Clock));
// k3  POSITIONAL, ELEMENT SELECT actual
if1 d3[4](Vec[0]);
// k4  NAMED, ELEMENT SELECT actual
if1 d4[4](.clk(Vec[0]));
// k5  POSITIONAL, OPERATION actual (not a NamedValue: the producer skips it)
if1 d5[4](Clock & 1'b1);
// k6  NAMED, OPERATION actual
if1 d6[4](.clk(Clock & 1'b1));
// k7  POSITIONAL, LITERAL actual
if1 d7[4](1'b0);

endmodule
