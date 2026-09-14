// m11 — THE FLATTEN CONTROL, READ BY A PLAIN LOCALPARAM (no const function).
// `localparam in_t VV = UU;` and `localparam int unsigned AA = UU.a;` both
// reach `getValue("UU")`.  If the elaborated UU Rhs is flattened HERE too, the
// flatten belongs to the READ, not to the const-function machinery.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  localparam in_t UU = '{a: 11, b: 22};
  localparam in_t VV = UU;
  localparam int unsigned AA = UU.a;
endpackage

module dut(output logic o);
  assign o = 1'b0;
endmodule
