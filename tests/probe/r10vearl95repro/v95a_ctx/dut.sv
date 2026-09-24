// r10v95 -- adversarial arm A: the CONTEXT axis.  The same select statement in
// a module body, a gen-if, a gen-case, a gen-for and a nested gen scope, with
// the parameter it reads declared at distance 0 / 1 / 2 from the emitting
// block.  Three instantiations of one span.
module ctx95 #(parameter int W = 8) (
  input  logic [31:0] din,
  output logic [7:0]  m0,
  output logic [7:0]  gi1, gi2, gi3,
  output logic [7:0]  gc1, gc2,
  output logic [7:0]  gf1, gf2,
  output logic [7:0]  nn1, nn2, nn3
);
  localparam int MP  = 3;
  localparam logic [63:0] TBL [0:3] = '{64'd1, 64'd2, 64'd3, 64'd4};

  // plain module body -- no generate scope at all (control)
  assign m0 = TBL[MP-1][7:0];

  // gen-if depth 1: MP is at distance 1
  if (W > 0) begin : gi_a
    localparam int L1 = 2;                    // distance 0 from gi_a
    assign gi1 = TBL[MP-1][7:0];              // distance 1  -> golden folds
    assign gi2 = TBL[L1-1][7:0];              // distance 0  -> golden keeps
    // gen-if depth 2 nested here
    if (W > 0) begin : gi_b
      assign gi3 = TBL[MP-1][7:0];            // distance 2  -> golden keeps
      assign nn1 = TBL[L1-1][7:0];            // distance 1 (parent gen scope)
    end
  end

  // gen-case depth 1 and its nested gen-if
  case (W)
    default: begin : gc_a
      localparam int C1 = 2;
      assign gc1 = TBL[MP-1][7:0];            // distance 1 from a CASE block
      if (W > 0) begin : gc_b
        assign gc2 = TBL[C1-1][7:0];          // distance 1: parent case block
        assign nn2 = TBL[MP-1][7:0];          // distance 2
      end
    end
  endcase

  // gen-for depth 1 and its nested gen-if (the LOOP half -- must not move)
  for (genvar gi = 0; gi < 1; gi++) begin : gf_a
    localparam int F1 = 2;
    assign gf1 = TBL[MP-1+gi][7:0];
    if (W > 0) begin : gf_b
      assign gf2 = TBL[F1-1][7:0];
      assign nn3 = TBL[MP-1][7:0];
    end
  end
endmodule

module v95a_ctx (input logic [31:0] din,
  output logic [7:0] a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,
  output logic [7:0] b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,
  output logic [7:0] c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10);
  ctx95 #(.W(8))  u8  (.din(din), .m0(a0), .gi1(a1),.gi2(a2),.gi3(a3), .gc1(a4),.gc2(a5), .gf1(a6),.gf2(a7), .nn1(a8),.nn2(a9),.nn3(a10));
  ctx95 #(.W(16)) u16 (.din(din), .m0(b0), .gi1(b1),.gi2(b2),.gi3(b3), .gc1(b4),.gc2(b5), .gf1(b6),.gf2(b7), .nn1(b8),.nn2(b9),.nn3(b10));
  ctx95 #(.W(32)) u32 (.din(din), .m0(c0), .gi1(c1),.gi2(c2),.gi3(c3), .gc1(c4),.gc2(c5), .gf1(c6),.gf2(c7), .nn1(c8),.nn2(c9),.nn3(c10));
endmodule
