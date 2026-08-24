// r10v81 arm v4 — THE isOverriddenParam SPAN TRAPS: a DEFAULT written through a
// MACRO (rawText maps a macro range back to the definition site, and
// isOverriddenParam compares ORIGINAL locations), an override written through a
// macro, a leading-zero/underscored macro actual, and a parameter with NO
// default.  MEASUREMENT ONLY.
`define TWO 2
`define OH 007
`define BASED 4'd5
module leafv4 (input logic ib, output logic o);
  assign o = ib;
endmodule

module midv4 #(
  parameter int unsigned MD = `TWO,   // DEFAULT through a macro, NOT overridden
  parameter int unsigned MO = 1,      // overridden with `TWO
  parameter int unsigned MZ = 1,      // overridden with `OH  (leading zeros)
  parameter int unsigned MB = 1,      // overridden with `BASED
  parameter int unsigned RQ            // NO DEFAULT, override-only
) (
  input  logic [15:0] w,
  output logic [15:0] y
);
  leafv4 uMD (.ib(w[MD]), .o(y[0]));
  leafv4 uMO (.ib(w[MO]), .o(y[1]));
  leafv4 uMZ (.ib(w[MZ]), .o(y[2]));
  leafv4 uMB (.ib(w[MB]), .o(y[3]));
  leafv4 uRQ (.ib(w[RQ]), .o(y[4]));
endmodule

module topv4 (input logic [15:0] w, output logic [15:0] y);
  midv4 #(.MO(`TWO), .MZ(`OH), .MB(`BASED), .RQ(6)) i0 (.w(w), .y(y));
endmodule
