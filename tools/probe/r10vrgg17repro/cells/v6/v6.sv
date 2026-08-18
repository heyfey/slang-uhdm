// vrgg17 v6 — the FENCE arm: hier_path port actuals that must NOT move, in the
// shapes the campaign already pinned (modport-restricted root, interface port
// re-passed, whole-interface port, plain struct root, non-generate home).
typedef struct packed { logic [31:0] a; logic [31:0] b; } s_t;
interface bif;
  logic [31:0] r;
  modport mp (input r);
endinterface
module leaf (input logic [3:0] d); endmodule
module mid1 (bif.mp p);
  leaf u1 (.d(p.r[0+:4]));           // modport-restricted root
endmodule
module mid2 (bif p);
  leaf u2 (.d(p.r[3:0]));            // whole-interface port
endmodule
module mid3 (interface p);
  leaf u3 (.d(p.r[0+:4]));           // GENERIC interface port
endmodule
module top;
  bif b();
  s_t st;
  logic [3:0] q;
  mid1 m1(b.mp);
  mid2 m2(b);
  mid3 m3(b);
  leaf u4 (.d(st.a[0+:4]));          // plain struct root, module scope
  leaf u5 (.d(b.r[0+:4]));           // interface INSTANCE named from the parent
endmodule
