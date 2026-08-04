// t4 — generic interface port: NAMED vs POSITIONAL connection, and
// name-matched (`I`) vs unmatched (`gen`) port names, all four combinations.
interface I;
logic [7:0] r;
bit R;
modport A (output R);
endinterface

module np (interface I);        // matched name, connected POSITIONALLY
  initial I.R = 1'b0;
endmodule

module nn (interface I);        // matched name, connected BY NAME
  initial I.R = 1'b0;
endmodule

module gp (interface gen);      // unmatched name, connected POSITIONALLY
  initial gen.R = 1'b1;
endmodule

module gn (interface gen);      // unmatched name, connected BY NAME
  initial gen.R = 1'b1;
endmodule

module top();
  I inst();
  np u_np (inst.A);
  nn u_nn (.I(inst.A));
  gp u_gp (inst.A);
  gn u_gn (.gen(inst.A));
endmodule
