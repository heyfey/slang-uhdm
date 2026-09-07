// r10v112 arm v5 -- EXTRA MUST-STAY FLOOR beside earl110's pair.
// MEASUREMENT ONLY.
//
//  s1  earl110's exact corpus shape (a parameter-bounded indexed part select
//      on a genvar-indexed base, PLAIN cont_assign) -- MUST STAY
//  s2  the same select half inside a pattern member value -- fence (c)
//  s3  a genvar index on the MEMBER of a pattern-carried path (two brackets)
//  s4  a genvar index inside a pattern that sits in a gen-scope ALWAYS_FF
//  s5  a gen-scope cont_assign pattern whose member value is a whole struct
//      read (no select at all) -- MUST STAY
//  s6  a pattern member value under a gen-if with NO genvar in scope at all
//  s7  a genvar-indexed path inside a pattern inside a MODULE-scope generate
//      block that is a gen-case
package pv5_112;
  typedef struct packed {
    logic       a_valid;
    logic [7:0] a_source;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module v5_floor112 #(parameter int M = 3, parameter int CS = 1) (
  input  logic          clk,
  input  pv5_112::h2d_t tl_h_i [M],
  output logic [7:0]    s1_o,
  output pv5_112::h2d_t s5_o,
  output pv5_112::h2d_t s6_o
);
  localparam int unsigned IDW   = 8;
  localparam int unsigned STIDW = 2;

  for (genvar i = 0; i < M; i++) begin : gen_s
    pv5_112::h2d_t s2, s3, s4;

    // s1  earl110's shape, PLAIN cont_assign -- MUST STAY BYTE-IDENTICAL
    assign s1_o = tl_h_i[i].a_source[IDW-1 -: STIDW];

    // s2  the same select half inside a pattern member value (fence (c))
    assign s2 = '{ a_valid:  tl_h_i[i].a_valid,
                   a_source: {6'b0, tl_h_i[i].a_source[IDW-1 -: STIDW]},
                   a_data:   tl_h_i[i].a_data };

    // s3  a genvar index on the MEMBER as well as on the base
    assign s3 = '{ a_valid:  tl_h_i[i].a_source[i],
                   a_source: tl_h_i[i].a_source,
                   a_data:   tl_h_i[i].a_data };

    // s4  a pattern inside a gen-scope ALWAYS_FF -- procedural, outside the law
    always_ff @(posedge clk)
      s4 <= '{ a_valid:  tl_h_i[i].a_valid,
               a_source: tl_h_i[i].a_source,
               a_data:   tl_h_i[i].a_data };

    // s5  a pattern member value with NO select -- MUST STAY
    assign s5_o = '{ a_valid: 1'b1, a_source: 8'h5, a_data: 8'ha };
  end

  // s6  a gen-IF body with no genvar anywhere -- MUST STAY
  if (CS == 1) begin : gen_if
    assign s6_o = '{ a_valid:  tl_h_i[1].a_valid,
                     a_source: tl_h_i[1].a_source,
                     a_data:   tl_h_i[1].a_data };
  end

  // s7  a gen-CASE body inside a genvar loop
  for (genvar g = 0; g < 2; g++) begin : gen_cs
    case (CS)
      1: begin : gen_c1
        pv5_112::h2d_t s7;
        assign s7 = '{ a_valid:  tl_h_i[g].a_valid,
                       a_source: tl_h_i[g].a_source,
                       a_data:   tl_h_i[g].a_data };
      end
      default: begin : gen_c2
        pv5_112::h2d_t s7;
        assign s7 = '{ a_valid: 1'b0, a_source: 8'h0, a_data: 8'h0 };
      end
    endcase
  end
endmodule
