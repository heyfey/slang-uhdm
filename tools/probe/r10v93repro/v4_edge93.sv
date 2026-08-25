// v93 adversarial arm V4 — edge homes: specparam, class param, unpacked array,
// assignment pattern, typed narrow params, override actual, High_conn.
package v4pkg;
  typedef struct packed { logic [63:0] a; logic [63:0] b; } p128_t;
endpackage

module v4_sink #(parameter logic [63:0] SEED = 64'd0)
                (input logic [63:0] i, output logic [63:0] o);
  localparam logic [63:0] L_seed = SEED;
  assign o = i ^ SEED ^ L_seed;
endmodule

module v4_top (input logic clk, output logic [63:0] o);
  import v4pkg::*;
  localparam logic [63:0] ALLONES = 64'hFFFF_FFFF_FFFF_FFFF;
  // narrow declared types
  parameter int          P_int   = 96'(64'hFFFF_FFFF_FFFF_FFFF);
  parameter int unsigned P_uint  = 96'(64'hFFFF_FFFF_FFFF_FFFF);
  parameter byte         P_byte  = 96'(64'hFFFF_FFFF_FFFF_FFFF);
  parameter              P_bare  = 64'(64'hFFFF_FFFF_FFFF_FFFF);
  parameter logic [7:0]  P_v8    = 65'(64'hFFFF_FFFF_FFFF_FFFF);
  parameter logic [127:0] P_v128 = 96'(64'hFFFF_FFFF_FFFF_FFFF);
  // signed target parameter, positive value
  parameter logic signed [63:0] P_sp = 96'(64'h0000_0000_0000_0005);
  // unpacked array of casts
  parameter logic [63:0] P_ua [0:1] = '{ 64'(64'hFFFF_FFFF_FFFF_FFFF),
                                         96'(64'hFFFF_FFFF_FFFF_FFFF) };
  // packed struct assignment pattern with cast members
  parameter p128_t P_st = '{ a: 64'(64'hFFFF_FFFF_FFFF_FFFF),
                             b: 96'(64'hFFFF_FFFF_FFFF_FFFF) };
  // top-level shapes that must NOT fire
  parameter logic [63:0] P_neg  = -64'(64'd1);
  parameter logic [63:0] P_cat  = {64'(64'd1)};
  parameter logic [63:0] P_add  = 64'(64'd1) + 64'd0;
  parameter logic [63:0] P_tern = (1) ? 64'(64'd1) : 64'd0;
  // cont_assign fence
  logic [63:0] w_ca64, w_ca96;
  assign w_ca64 = 64'(64'hFFFF_FFFF_FFFF_FFFF);
  assign w_ca96 = 96'(64'hFFFF_FFFF_FFFF_FFFF);
  // procedural
  logic [63:0] r_pr;
  always_comb r_pr = 64'(64'hFFFF_FFFF_FFFF_FFFF);
  // High_conn actual and an override actual that is a cast
  logic [63:0] s_o;
  v4_sink #(.SEED(96'(64'hFFFF_FFFF_FFFF_FFFF))) u_s (.i(64'(ALLONES)), .o(s_o));
  specify
    specparam SP = 64'd3;
  endspecify
  assign o = s_o ^ w_ca64 ^ w_ca96 ^ r_pr ^ P_v128[63:0] ^ P_ua[0] ^ P_ua[1]
           ^ P_st.a ^ P_st.b ^ P_neg ^ P_cat ^ P_add ^ P_tern ^ P_bare
           ^ {56'd0, P_byte} ^ {32'd0, P_int} ^ {32'd0, P_uint} ^ {56'd0, P_v8}
           ^ P_sp ^ {61'd0, SP} ^ {64{clk}};
endmodule
