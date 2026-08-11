// r10uvm51 arm a3 — THE VIEW-SCOPE DECIDER.
// The brief's open cell: "what does golden do in the ELABORATED view, where the
// type parameter has a REAL type?  If golden emits an index typespec there and
// nothing in the def view, the law is VIEW-SCOPED and a blanket suppression
// would break the elab view."
//
// Classes cannot answer it — Surelog never specializes a parameterized class
// body (measured in a1/a2: ONE `class_defn` per generic class, no `#(...)`
// object anywhere).  MODULES can: Surelog elaborates one module_inst per
// instantiation with the override applied, so `u1` below carries MK=string and
// `u2` carries the default `int`.
module sub51 #(parameter type MK = int, parameter int W = 4);
  int p_tp[MK];        // index IS the module's type parameter
  int p_ctl[string];   // control at the same site
  logic [W-1:0] v;     // a packed bound that is a VALUE parameter
endmodule

module a3_top;
  sub51 #(.MK(string), .W(8)) u1 ();   // MK OVERRIDDEN with a concrete type
  sub51 u2 ();                          // MK left at its default
endmodule
