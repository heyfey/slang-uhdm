// r10v95 -- adversarial arm D: a DEFPARAM'd instance and a PORT parameter, at
// gen depth 1 and 2.  defparam changes the value AFTER elaboration order, so
// the folded constant must track the overridden value or the fold must abstain.
module dleaf95 #(parameter int W = 8, parameter int DP = 3) (
  input logic [31:0] din, output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3);
  localparam logic [63:0] TBL [0:7] = '{64'd0,64'd1,64'd2,64'd3,64'd4,64'd5,64'd6,64'd7};
  if (W > 0) begin : dd1
    assign o1 = TBL[DP-1][7:0];        // PORT parameter, distance 1
    assign o3 = TBL[(W>>2)-1][7:0];         // the other PORT parameter, distance 1
    if (W > 0) begin : dd2
      assign o2 = TBL[DP-1][7:0];      // distance 2
    end
  end
endmodule

module v95d_defp (input logic [31:0] din,
  output logic [7:0] a1,a2,a3, b1,b2,b3, c1,c2,c3);
  dleaf95 #(.W(8),  .DP(3)) u_a (.din(din), .o1(a1), .o2(a2), .o3(a3));
  dleaf95 #(.W(16), .DP(5)) u_b (.din(din), .o1(b1), .o2(b2), .o3(b3));
  dleaf95                   u_c (.din(din), .o1(c1), .o2(c2), .o3(c3));
  defparam u_c.DP = 6;
  defparam u_c.W  = 32;
endmodule
