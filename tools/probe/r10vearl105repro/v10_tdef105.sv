// r10v105 v10 — THE TYPEDEF'D PREDEFINED-INTEGER PARAMETER, isolated so the
// JUDGE can speak.  `intAtom105` is `getCanonicalType().isPredefinedInteger()`,
// which a `typedef int` satisfies — but golden's CLONE carries the TYPEDEF's
// NAME on its `int_typespec`, and `BaseClass::Compare` reads `VpiName`.
module v10_leaf105 (input logic [31:0] sig, output logic [63:0] z);
  typedef int v10_myint_t;
  localparam v10_myint_t TD  = 4'hA;
  localparam int         PL  = 4'hA;
  for (genvar i = 0; i < 2; i++) begin : gen_td
    logic [63:0] t0, t1;
    assign t0 = TD ^ sig;
    assign t1 = PL ^ sig;
  end
  assign z = 64'b0;
endmodule

module v10_tdef105 (input logic [31:0] sig, output logic [63:0] z);
  logic [63:0] zc;
  v10_leaf105 u_leaf (.sig(sig), .z(zc));
  assign z = zc;
endmodule
