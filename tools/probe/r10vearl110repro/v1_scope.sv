// r10vearl110 arm v1 -- SCOPE FACES the implementer's g6 never varied.
// g6 measured: module body / for d1 / for d2 / if d1 / if-inside-for d2.
// It NEVER varied: a PROCEDURAL block INSIDE a depth-1 generate, a FUNCTION
// body inside one, a CASE generate, a FOR inside an IF (the other nesting
// order), an UNNAMED generate block, or an instance PORT CONNECTION inside one.
// Each of these is a place the patch's genDepth110(parent)==1 gate can fire.
package pv1;
  typedef struct packed { logic [31:0] fld; } c_t;
endpackage

module v1_sink(input logic [31:0] a);
endmodule

module v1_scope #(parameter int unsigned NCH = 2) (
  input  pv1::c_t chan [NCH],
  output logic [31:0] oz
);
  localparam int unsigned SA = 9;
  localparam int unsigned SB = 3;
  logic [31:0] w1, w2, w3, w4, w5, w6, w7;

  function automatic logic [31:0] fn1(input pv1::c_t x);
    return {26'b0, x.fld[0+:(SA-SB)]};
  endfunction

  // a1 -- depth-1 for, select in an ALWAYS_COMB (procedural inside a gen scope)
  for (genvar z = 0; z < NCH; z++) begin : blk_a
    always_comb w1 = {26'b0, chan[z].fld[0+:(SA-SB)]};
  end

  // a2 -- depth-1 for, select in an INITIAL block
  for (genvar z = 0; z < NCH; z++) begin : blk_b
    initial w2 = {26'b0, chan[z].fld[0+:(SA-SB)]};
  end

  // a3 -- depth-1 for, select in an ALWAYS_FF
  for (genvar z = 0; z < NCH; z++) begin : blk_c
    logic clk_c;
    always_ff @(posedge clk_c) w3 <= {26'b0, chan[z].fld[0+:(SA-SB)]};
  end

  // a4 -- depth-1 for, select inside a FUNCTION declared in the gen scope
  for (genvar z = 0; z < NCH; z++) begin : blk_d
    function automatic logic [31:0] fn2(input pv1::c_t y);
      return {26'b0, y.fld[0+:(SA-SB)]};
    endfunction
    assign w4 = fn2(chan[z]);
  end

  // a5 -- a CASE generate, depth 1
  case (NCH)
    2: begin : blk_e
      assign w5 = {26'b0, chan[0].fld[0+:(SA-SB)]};
    end
    default: begin : blk_f
      assign w5 = 32'b0;
    end
  endcase

  // a6 -- a FOR inside an IF (depth 2, the nesting order g6 v9 did NOT test)
  if (NCH > 1) begin : blk_g
    for (genvar z = 0; z < NCH; z++) begin : blk_h
      assign w6 = {26'b0, chan[z].fld[0+:(SA-SB)]};
    end
  end

  // a7 -- depth-1 for, select in an INSTANCE PORT CONNECTION
  for (genvar z = 0; z < NCH; z++) begin : blk_i
    v1_sink u_sink (.a({26'b0, chan[z].fld[0+:(SA-SB)]}));
  end

  assign w7 = fn1(chan[0]);
  assign oz = w1 ^ w2 ^ w3 ^ w4 ^ w5 ^ w6 ^ w7;
endmodule
