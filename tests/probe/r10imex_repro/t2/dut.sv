// t2 — GENERIC interface port whose PORT NAME matches an interface def name
// (sub's port `I`) paired with one whose name matches nothing (`gen`).
interface I;
logic [7:0] r;
bit R;
modport A (output R);
endinterface

module sub (interface I);
  initial I.R = 1'b0;
endmodule

module other (interface gen);
  initial gen.R = 1'b1;
endmodule

module top();
  I inst();
  sub s (inst.A);
  other o (inst.A);
endmodule
