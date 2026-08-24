// r10v81 arm v7 — THE NEIGHBOURING FOLD LAWS that must NOT move: an ENUM
// CONSTANT as the port-High_conn bit-select index (§ elabConnEnumConstFold66),
// a package enum member, a `$bits` expression index, and a `bind`-statement
// port connection carrying the overridden-parameter index.  MEASUREMENT ONLY.
package pe81;
  typedef enum int unsigned { PE_A = 1, PE_B = 2 } pe_t;
  parameter int unsigned PPAR = 3;
endpackage

module leafv7 (input logic ib, output logic o);
  assign o = ib;
endmodule

module midv7 #(parameter int unsigned N = 1)
              (input logic [15:0] w, output logic [15:0] y);
  import pe81::*;
  typedef enum int unsigned { LE_A = 4, LE_B = 5 } le_t;
  leafv7 uEnumLocal (.ib(w[LE_B]),   .o(y[0]));   // module-scope enum const
  leafv7 uEnumPkg   (.ib(w[PE_B]),   .o(y[1]));   // package enum const
  leafv7 uBits      (.ib(w[$bits(w) - 15]), .o(y[2]));
  leafv7 uOvr       (.ib(w[N]),      .o(y[3]));   // the law's own cell
  // body-position twins
  assign y[4] = w[LE_B];
  assign y[5] = w[PE_B];
endmodule

module bindtgt81 (input logic [15:0] w, output logic o);
  assign o = ^w;
endmodule

module topv7 (input logic [15:0] w, output logic [15:0] y, output logic bo);
  midv7 #(.N(2)) i0 (.w(w), .y(y));
  bindtgt81 ub (.w(w), .o(bo));
endmodule

// a BIND-created instance whose port High_conn carries a select
bind bindtgt81 leafv7 ubound (.ib(w[1]), .o());
