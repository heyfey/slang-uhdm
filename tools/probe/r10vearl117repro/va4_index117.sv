// r10vearl117 ADVERSARIAL arm va4_index117 — THE INDEX-FORM FACES
// (earl113's namesake axis: genvars vs GEN-LOCAL PARAMETERS, plus the
// unknown-size / unsized constant faces the brief names).
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
//   u1  the genvar DECLARED OUTSIDE the loop (`genvar i; for (i = ...)`)
//   u2  a gen-scope localparam INITIALISED FROM the genvar (`localparam LX = i`)
//   u3  a gen-scope localparam NOT from the genvar
//   u4  an UNSIZED decimal constant index (`'d2`)
//   u5  an UNSIZED hex constant index (`'h1`)
//   u6  an explicit CAST of the genvar (`int'(i)`)
//   u7  a module parameter index (already folded by an earlier law)
//   u8  the bare genvar (control: must FOLD)
//   u9  a genvar-indexed select whose VALUE feeds a PART-SELECT bound in the
//       same pattern (earl110's must-stay neighbour)
package vu117;
  typedef struct packed {
    logic [3:0] u1;
    logic [3:0] u2;
    logic [3:0] u3;
    logic [3:0] u4;
  } uq_t;
  typedef struct packed {
    logic [3:0] u5;
    logic [3:0] u6;
    logic [3:0] u7;
    logic [3:0] u8;
  } ur_t;
endpackage

module va4_index117 #(
    parameter int NW = 3,
    parameter int MW = 2
) (
    input  logic [7:0] din,
    output logic [3:0] dout
);
  logic [7:0]  UBUS;
  vu117::uq_t  za [NW];
  vu117::ur_t  zb [NW];
  logic [1:0]  zc [NW];

  assign UBUS = din;

  genvar i;                                    // DECLARED OUTSIDE the loop
  for (i = 0; i < NW; i++) begin : gen_out
    localparam int LX = i;                     // localparam FROM the genvar
    localparam int LY = 1;                     // localparam NOT from the genvar
    assign za[i] = '{
      u1: {3'b0, UBUS[i]},                     // u1 outside-declared genvar
      u2: {3'b0, UBUS[LX]},                    // u2 localparam from the genvar
      u3: {3'b0, UBUS[LY]},                    // u3 plain gen-scope localparam
      u4: {3'b0, UBUS['d2]}                    // u4 UNSIZED decimal constant
    };
    assign zb[i] = '{
      u5: {3'b0, UBUS['h1]},                   // u5 UNSIZED hex constant
      u6: {3'b0, UBUS[int'(i)]},               // u6 an explicit CAST
      u7: {3'b0, UBUS[MW]},                    // u7 a module parameter
      u8: {3'b0, UBUS[i]}                      // u8 the bare genvar (control)
    };
    // u9 a PART-SELECT bound in the same pattern position — MUST STAY SPELLED
    assign zc[i] = UBUS[i+1:i];
  end

  assign dout = za[0].u1 ^ zb[0].u8 ^ {2'b0, zc[0]};
endmodule
