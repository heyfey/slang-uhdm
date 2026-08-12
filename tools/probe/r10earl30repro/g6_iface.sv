// r10earl30 arm g6_iface.sv — THE SECOND CALL SITE.
//
// `src/ModuleEmit.cpp` ~23806 carries the SAME value-prefix -> vpiConstType
// chain as `src/ExprEmit.cpp` ~5169 and is missing the SAME `INT:` arm.  Its
// origin is an INTERFACE's elab-view cont_assign whose RHS ref binds a PACKAGE
// enum const: golden folds that to a LOC-LESS constant carrying the enum_const's
// own encoding, so an implicit member (INT:) must read vpiConstType 7 there too.
// This arm exists so that site is MEASURED and not fixed by analogy.
package p6;
  typedef enum logic [2:0] { X0, X1, X2 } x_t;
  typedef enum logic [3:0] { Y0 = 4'h0, Y1 = 4'h5 } y_t;   // HEX member: control
  typedef enum logic [2:0] { Z0 = 0,    Z1 = 1    } z_t;   // UNSIZED member: control
endpackage

interface if6;
  logic [2:0] a;
  logic [2:0] b;
  logic [3:0] h;
  logic [2:0] u;
  // i1  implicit member -> enum_const INT:  (the predicted mover)
  assign a = p6::X0;
  // i2  implicit member, nonzero
  assign b = p6::X2;
  // i3  HEX member -> enum_const HEX:      (must stay vpiHexConst)
  assign h = p6::Y1;
  // i4  UNSIZED-decimal member -> enum_const UINT: (must stay vpiUIntConst)
  assign u = p6::Z1;
endinterface

module g6_iface (output logic [2:0] o);
  if6 bus ();
  assign o = bus.a ^ bus.b ^ bus.u ^ bus.h[2:0];
endmodule
