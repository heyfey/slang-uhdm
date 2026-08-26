// r10v95 -- adversarial arm E: the two SPLICES.  § genElseArmCollapse48 (a
// taken plain-else arm is replaced by its first if-generate item) and
// genHoists9 (an unnamed block holding only generate children is hoisted).
// Each survivor reads a parameter declared at every reachable level, so the
// EMITTED hop count and the SYNTACTIC hop count disagree cell by cell.
module coll95 #(parameter int W = 8) (
  input logic [31:0] din,
  output logic [7:0] x1, x2, x3, x4, x5, x6, x7, x8);
  localparam int MP = 3;
  localparam logic [63:0] TBL [0:7] = '{64'd0,64'd1,64'd2,64'd3,64'd4,64'd5,64'd6,64'd7};

  // ---- the ELSE-ARM COLLAPSE: c_else's level disappears, c_in takes it ----
  if (W == 0) begin : c_then
    assign x1 = 8'd0;
    assign x2 = 8'd0;
  end
  else begin : c_else
    localparam int EP = 2;              // declared in the DROPPED arm
    if (W > 0) begin : c_in
      assign x1 = TBL[MP-1][7:0];       // syntactic distance 2, EMITTED 1
      assign x2 = TBL[EP-1][7:0];       // syntactic distance 1, EMITTED 0
    end
  end

  // ---- the same collapse ONE LEVEL DEEPER --------------------------------
  if (W > 0) begin : c_out
    localparam int OP = 2;
    if (W == 0) begin : c_t2
      assign x3 = 8'd0;
      assign x4 = 8'd0;
    end
    else begin : c_e2
      if (W > 0) begin : c_i2
        assign x3 = TBL[OP-1][7:0];     // syntactic 2, EMITTED 1 (c_out)
        assign x4 = TBL[MP-1][7:0];     // syntactic 3, EMITTED 2
      end
    end
  end

  // ---- the UNNAMED HOIST: the outer anonymous block is spliced out -------
  if (W > 0)
    if (W > 0) begin : h_in
      assign x5 = TBL[MP-1][7:0];       // syntactic 2, EMITTED 1
    end

  // ---- a flat NAMED control at depth 1 and a nested one at depth 2 -------
  if (W > 0) begin : f_top
    assign x6 = TBL[MP-1][7:0];         // distance 1 both ways
    if (W > 0) begin : f_in
      assign x7 = TBL[MP-1][7:0];       // distance 2 both ways
    end
  end
  // an unnamed depth-1 block holding a cont_assign never hoists
  if (W > 0)
    assign x8 = TBL[MP-1][7:0];
endmodule

module v95e_collapse (input logic [31:0] din,
  output logic [7:0] a1,a2,a3,a4,a5,a6,a7,a8,
  output logic [7:0] b1,b2,b3,b4,b5,b6,b7,b8,
  output logic [7:0] c1,c2,c3,c4,c5,c6,c7,c8);
  coll95 #(.W(8))  u8  (.din(din), .x1(a1),.x2(a2),.x3(a3),.x4(a4),.x5(a5),.x6(a6),.x7(a7),.x8(a8));
  coll95 #(.W(16)) u16 (.din(din), .x1(b1),.x2(b2),.x3(b3),.x4(b4),.x5(b5),.x6(b6),.x7(b7),.x8(b8));
  coll95 #(.W(32)) u32 (.din(din), .x1(c1),.x2(c2),.x3(c3),.x4(c4),.x5(c5),.x6(c6),.x7(c7),.x8(c8));
endmodule
