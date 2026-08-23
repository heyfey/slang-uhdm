// r10v77 -- ADVERSARIAL grid B: the same scoped-typedef port shape in every
// INSTANCE HOME: module scope, generate-for, generate-if (taken and not),
// NESTED generate, an INSTANCE ARRAY, an interface, a program.  1..3 instances.
package b77;
  typedef logic [7:0] v8_t;
  typedef enum logic [1:0] { B770, B771 } e_t;
endpackage

module leafB (
  input  b77::v8_t i_pv,
  output b77::v8_t o_pv,
  inout  b77::v8_t b_pv,
  input  logic [7:0] i_plain,
  output logic [7:0] o_plain
);
  assign o_pv = i_pv;
  assign o_plain = i_plain;
endmodule

interface ifB (
  input  b77::v8_t if_in,
  output b77::v8_t if_out
);
  b77::v8_t if_body;
  modport mp (input if_in, output if_out);
endinterface

program prgB (
  input  b77::v8_t p_in,
  output b77::v8_t p_out
);
  b77::v8_t p_body;
endprogram

module userB (if77_ifc);
  input  b77::v8_t if77_ifc;
endmodule

module topB;
  logic [7:0] a, b, c, d, e, f;
  wire  [7:0] zz;

  // 1. plain module scope
  leafB u_m (.i_pv(a), .o_pv(b), .b_pv(zz), .i_plain(c), .o_plain(d));

  // 2. generate-for, 3 iterations
  genvar gi;
  generate
    for (gi = 0; gi < 3; gi++) begin : g_for
      logic [7:0] fa, fb;
      leafB u_f (.i_pv(fa), .o_pv(fb), .b_pv(zz), .i_plain(fa), .o_plain(fb));
    end
  endgenerate

  // 3. generate-if, taken and not taken
  parameter int TAKE = 1;
  generate
    if (TAKE == 1) begin : g_if_t
      logic [7:0] ta, tb;
      leafB u_t (.i_pv(ta), .o_pv(tb), .b_pv(zz), .i_plain(ta), .o_plain(tb));
    end
    else begin : g_if_f
      logic [7:0] xa, xb;
      leafB u_x (.i_pv(xa), .o_pv(xb), .b_pv(zz), .i_plain(xa), .o_plain(xb));
    end
  endgenerate

  // 4. NESTED generate
  generate
    if (TAKE == 1) begin : g_outer
      for (genvar gj = 0; gj < 2; gj++) begin : g_inner
        logic [7:0] na, nb;
        leafB u_n (.i_pv(na), .o_pv(nb), .b_pv(zz), .i_plain(na), .o_plain(nb));
      end
    end
  endgenerate

  // 5. INSTANCE ARRAY
  logic [7:0] ar_i [0:2];
  logic [7:0] ar_o [0:2];
  leafB u_arr [2:0] (.i_pv({ar_i[2],ar_i[1],ar_i[0]}), .o_pv(), .b_pv(zz),
                     .i_plain({ar_i[2],ar_i[1],ar_i[0]}), .o_plain());

  // 6. interface + program homes
  ifB  u_if (.if_in(e), .if_out(f));
  prgB u_pg (.p_in(e), .p_out());
endmodule
