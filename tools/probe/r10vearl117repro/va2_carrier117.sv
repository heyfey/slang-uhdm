// r10vearl117 ADVERSARIAL arm va2_carrier117 — THE CARRIER FACES THE
// IMPLEMENTER'S p1_car117 DID NOT SPELL.
//
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
//   b1  a WHOLE unpacked-array element (`UMEM[j]`, no inner bit)
//   b2  a bit-select on a WIRE NET (the head's carrier is a logic_var)
//   b3  a module PARAMETER-array element
//   b4  a GEN-SCOPE LOCALPARAM-array element
//   b5  a 2-D UNPACKED select, genvar in the FIRST dimension
//   b6  a bit-select on a packed vector, index the genvar, in a NESTED pattern
//   b7  the head shape itself (control: must FOLD)
//   b8  a HIERARCHICAL select `gen_other[0].osig[j]` inside a pattern value
//   b9  a bit-select on an unpacked-array element accessed with TWO indices
//       where the SECOND is the genvar (`U2[0][j]`)
//   b10 the same carrier OUTSIDE any pattern in the same gen scope (control:
//       must SPELL)
package vq117;
  typedef struct packed {
    logic [3:0] c1;
    logic [3:0] c2;
    logic [3:0] c3;
    logic [3:0] c4;
  } cq_t;
  typedef struct packed {
    logic [3:0] c5;
    logic [3:0] c6;
    logic [3:0] c7;
    logic [3:0] c8;
  } cr_t;
  typedef struct packed {
    logic [3:0] d1;
    logic [3:0] d2;
  } cd_t;
endpackage

module va2_carrier117 #(
    parameter int NW = 4
) (
    input  logic [7:0] din,
    output logic [3:0] dout
);
  wire  [7:0]  WNET;
  logic [7:0]  PKV;
  logic [3:0]  UMEM [NW];
  logic [3:0]  U2   [NW][NW];
  vq117::cq_t  ra [NW];
  vq117::cr_t  rb [NW];
  vq117::cd_t  rc [NW][2];
  logic [3:0]  rd [NW];

  localparam logic [3:0] MPARR [4] = '{4'h1, 4'h2, 4'h3, 4'h4};

  assign WNET = din;
  assign PKV  = din;

  for (genvar h = 0; h < 1; h++) begin : gen_other
    logic [7:0] osig;
    assign osig = din;
  end

  for (genvar f = 0; f < NW; f++) begin : gen_fill2
    assign UMEM[f] = din[3:0];
    for (genvar g = 0; g < NW; g++) begin : gen_fill3
      assign U2[f][g] = din[3:0];
    end
  end

  for (genvar j = 0; j < NW; j++) begin : gen_car
    localparam logic [3:0] LARR [4] = '{4'h5, 4'h6, 4'h7, 4'h8};

    assign ra[j] = '{
      c1: UMEM[j],                          // b1 WHOLE unpacked element
      c2: {3'b0, WNET[j]},                  // b2 a WIRE net bit-select
      c3: MPARR[j],                         // b3 module localparam array
      c4: LARR[j]                           // b4 gen-scope localparam array
    };
    assign rb[j] = '{
      c5: U2[j][0],                         // b5 2-D unpacked, first dim
      c6: U2[0][j],                         // b9 2-D unpacked, second dim
      c7: {3'b0, PKV[j]},                   // b7 the head shape (control)
      c8: {3'b0, gen_other[0].osig[j]}      // b8 HIERARCHICAL select
    };
    // b6 the same bit-select inside a pattern NESTED in a pattern (depth 2)
    assign rc[j] = '{'{d1: {3'b0, PKV[j]}, d2: 4'h0},
                     '{d1: 4'h0, d2: {3'b0, WNET[j]}}};
    // b10 the CONTROL: same carrier, same scope, NO pattern
    assign rd[j] = {3'b0, PKV[j]} ^ {3'b0, WNET[j]};
  end

  assign dout = ra[0].c1 ^ rb[0].c5 ^ rc[0][0].d1 ^ rd[0];
endmodule
