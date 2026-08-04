// t6 — modport EXPRESSION ports with TWO instances of the interface:
// which instance's variable does the DEF-view io_decl ref_obj bind to?
interface I;
logic [7:0] r;
int x;
modport A (output .P(r[3:0]), input .Q(x));
endinterface

module top();
  I i1();
  I i2();
endmodule
