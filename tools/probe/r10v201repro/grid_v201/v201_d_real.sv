// v201 arm D — REAL and STRING reference chains.  Surelog's implicit-type
// switch gives a real default a real_typespec and a string default a
// string_typespec; a mint that always builds an int_typespec would show here.
package p201vd;
  parameter D_RA = 1.5;
  parameter D_RB = D_RA;
  parameter D_SA = "abc";
  parameter D_SB = D_SA;
  parameter real D_RT = 2.5;
  parameter D_RC = D_RT;
endpackage
import p201vd::*;
module m201vd;
endmodule
