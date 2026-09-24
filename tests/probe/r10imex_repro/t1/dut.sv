// t1 — modport EXPRESSION ports only (no generic port, no const).
interface I;
logic [7:0] r;
int x;
bit R;
modport A (output .P(r[3:0]), input .Q(x), R);
modport B (output .P(r[7:4]), input .Q(2), R);
endinterface

module top();
  I inst();
endmodule
