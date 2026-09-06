// r10earl110 arm g3 -- THE HOMES.  The same half in every slot the emitter can
// reach it from, so "the law fires where the corpus put it" is not mistaken
// for "the law fires only there".
package pk3_110;
  typedef struct packed { logic [31:0] wrd; } box_t;
endpackage

module g3_home110 #(parameter int unsigned NSL = 2) (
  input  pk3_110::box_t slot [NSL],
  input  logic          gclk,
  output logic [31:0]   hres
);
  localparam int unsigned HA = 7;
  localparam int unsigned HB = 2;
  logic [31:0] h1, h2, h3, h4, h5, h6, h7;
  // h1  plain module-scope continuous assign, NO generate
  assign h1 = { 27'b0, slot[0].wrd[0+:(HA-HB)] };
  // h2  always_comb
  always_comb h2 = { 27'b0, slot[0].wrd[0+:(HA-HB)] };
  // h3  initial
  initial h3 = { 27'b0, slot[1].wrd[0+:(HA-HB)] };
  // h4  clocked always_ff
  always_ff @(posedge gclk) h4 <= { 27'b0, slot[0].wrd[(HA-HB)+:4] };
  // h5  an IF-generate body
  if (NSL > 1) begin : blk_if
    assign h5 = { 27'b0, slot[1].wrd[0+:(HA-HB)] };
  end else begin : blk_else
    assign h5 = 32'b0;
  end
  // h6  a NESTED generate-for
  for (genvar a3 = 0; a3 < 1; a3++) begin : blk_out
    for (genvar b3 = 0; b3 < 1; b3++) begin : blk_in
      assign h6 = { 27'b0, slot[0].wrd[0+:(HA-HB)] };
    end
  end
  // h7  inside a function body (a non-elaborated home)
  function automatic logic [31:0] pick3(input int unused3);
    return { 27'b0, slot[0].wrd[0+:(HA-HB)] };
  endfunction
  assign h7 = pick3(0);
  assign hres = h1 ^ h2 ^ h3 ^ h4 ^ h5 ^ h6 ^ h7;
endmodule
