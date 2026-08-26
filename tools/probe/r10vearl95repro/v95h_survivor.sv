// r10v95 -- adversarial arm H: an ELSE ARM that DOES collapse (its first item
// is a named if-generate), so the survivor is emitted at depth 1 while its
// SYNTACTIC depth is 2.  A syntax-tree hop count refuses here; golden folds.
module surv95 #(parameter int W = 8) (input logic [31:0] din,
  output logic [7:0] y1, output logic [7:0] y2, output logic [7:0] y3);
  localparam int MP = 3;
  localparam int NP = 2;
  localparam logic [63:0] TBL [0:7] = '{64'd0,64'd1,64'd2,64'd3,64'd4,64'd5,64'd6,64'd7};

  if (W == 0) begin : s_then
    assign y1 = 8'd0;
    assign y2 = 8'd0;
  end
  else begin : s_else            // FIRST item is a named if-generate -> collapses
    if (W > 0) begin : s_in
      assign y1 = TBL[MP-1][7:0];   // MODULE param: syntactic 2, EMITTED 1
      if (W > 0) begin : s_deep
        assign y2 = TBL[NP-1][7:0]; // syntactic 3, EMITTED 2 -> golden keeps
      end
    end
  end

  if (W > 0) begin : s_flat
    assign y3 = TBL[MP-1][7:0];     // the flat control, distance 1
  end
endmodule

module v95h_survivor (input logic [31:0] din,
  output logic [7:0] a1,a2,a3, b1,b2,b3, c1,c2,c3);
  surv95 #(.W(8))  u8  (.din(din), .y1(a1), .y2(a2), .y3(a3));
  surv95 #(.W(16)) u16 (.din(din), .y1(b1), .y2(b2), .y3(b3));
  surv95 #(.W(32)) u32 (.din(din), .y1(c1), .y2(c2), .y3(c3));
endmodule
