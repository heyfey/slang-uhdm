// r10earl4 aa.sv — § pkgTypespecInstanceIsTop.
// prim_pkg (14 Earlgrey AllModules heads) + prim_cipher_pkg (3) fail with
// "r=1 failLhs=package {top=1} failRhs=package {top=0}": golden's module-DEF
// view reaches the ELABORATED (uhdmtopPackages) package copy through a
// typespec's vpiInstance; we reach the DEFINITION copy.  Minimal shape: a
// package holding one enum typedef, named as a module parameter's type.
package ap;
  typedef enum integer {
    AImplGeneric,
    AImplXilinx
  } aimpl_e;
endpackage : ap

module am #(
  parameter ap::aimpl_e Impl = ap::AImplGeneric
) (
  input  logic i,
  output logic o
);
  assign o = i;
endmodule

module atop (input logic a, output logic b);
  am u_am (.i(a), .o(b));
endmodule
