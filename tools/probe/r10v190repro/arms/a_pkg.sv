// r10v190 arm 5, file 1 — the parameter's package, compiled as a SEPARATE file.
// If Surelog binds a typedef's range reference while COMPILING a later file
// (rather than in the writer's late-binding pass), a cross-FILE enum base is
// where it would show: by then the earlier package is fully compiled.
package pv5_a;
  parameter integer AW = 23;
  localparam integer AL = 17;
endpackage
