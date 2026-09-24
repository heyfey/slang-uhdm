// t7 — UNMATCHED generic interface port (`gen`, no interface of that name):
// PLAIN vs MODPORT-qualified actual x POSITIONAL vs NAMED connection.
interface I;
logic [7:0] r;
bit R;
modport A (output R);
endinterface

module pp (interface gen);      // plain actual, positional
  initial gen.R = 1'b0;
endmodule

module pn (interface gen);      // plain actual, by name
  initial gen.R = 1'b0;
endmodule

module mp (interface gen);      // modport actual, positional
  initial gen.R = 1'b0;
endmodule

module mn (interface gen);      // modport actual, by name
  initial gen.R = 1'b0;
endmodule

module top();
  I inst();
  pp u_pp (inst);
  pn u_pn (.gen(inst));
  mp u_mp (inst.A);
  mn u_mn (.gen(inst.A));
endmodule
