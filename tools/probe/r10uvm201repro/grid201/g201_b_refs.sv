// r10uvm201 grid arm B — THE HEAD SHAPE.  A parameter defaulted from a
// SIBLING PACKAGE PARAMETER REFERENCE, with the referent's own declared form
// varied: untyped-decimal, typed, unsized-based.  Plus the expression form
// the reference chain is built out of.
package p201b;
  parameter B_BASE = 13;
  parameter B_REFU = B_BASE;
  parameter int B_TI = 7;
  parameter B_REFT = B_TI;
  parameter B_UHEX = 'hf000000;
  parameter B_REFH = B_UHEX;
  parameter B_EXPR = B_BASE + 1;
endpackage
import p201b::*;
module m201b;
endmodule
