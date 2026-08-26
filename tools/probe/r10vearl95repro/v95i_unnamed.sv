// r10v95 -- adversarial arm I: UNNAMED generate blocks, the shapes on either
// side of genHoists9's guard.  Surelog's PARAMETER POOL follows the elaborated
// instance tree (which KEEPS an unnamed level) while reduceUnnamedBlocks_
// SPLICES that level out of the emitted model -- so the emitted hop count and
// the pool hop count part company exactly here.
module dummy95 (input logic [31:0] d, output logic [7:0] o);
  assign o = d[7:0];
endmodule

module unn95 #(parameter int W = 8) (input logic [31:0] din,
  output logic [7:0] z1, z2, z3, z4, z5, z6);
  localparam int MP = 3;
  localparam logic [63:0] TBL [0:7] = '{64'd0,64'd1,64'd2,64'd3,64'd4,64'd5,64'd6,64'd7};

  // (a) unnamed holding ONLY a named if-generate  -> hoists in both models
  if (W > 0)
    if (W > 0) begin : a_in
      assign z1 = TBL[MP-1][7:0];
    end

  // (b) unnamed holding a LOCALPARAM as well      -> level kept in both
  if (W > 0) begin
    localparam int BP = 2;
    if (W > 0) begin : b_in
      assign z2 = TBL[MP-1][7:0];     // module param, two levels up
      assign z3 = TBL[BP-1][7:0];     // the unnamed block's own, one level up
    end
  end

  // (c) unnamed holding a NET as well             -> level kept in both
  if (W > 0) begin
    wire [7:0] cw = din[7:0];
    if (W > 0) begin : c_in
      assign z4 = TBL[MP-1][7:0];
    end
  end

  // (d) unnamed holding a MODULE INSTANCE as well -> we keep, Surelog splices
  if (W > 0) begin
    dummy95 u_d (.d(din), .o());
    if (W > 0) begin : d_in
      assign z5 = TBL[MP-1][7:0];
    end
  end

  // (e) named depth-1 control
  if (W > 0) begin : e_top
    assign z6 = TBL[MP-1][7:0];
  end
endmodule

module v95i_unnamed (input logic [31:0] din,
  output logic [7:0] p1,p2,p3,p4,p5,p6, q1,q2,q3,q4,q5,q6);
  unn95 #(.W(8))  u8  (.din(din), .z1(p1),.z2(p2),.z3(p3),.z4(p4),.z5(p5),.z6(p6));
  unn95 #(.W(16)) u16 (.din(din), .z1(q1),.z2(q2),.z3(q3),.z4(q4),.z5(q5),.z6(q6));
endmodule
