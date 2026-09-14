// t1: a MODULE type-parameter DEFAULT whose packed range bound is an
// expression over a module localparam -- both keywords, both views.
module dut #(
    parameter  int  W  = 8,
    localparam int  V  = 4,
    parameter  type PT = logic [W-1:0],
    localparam type LT = logic [V-1:0]
) (input PT p, input LT l, output logic o);
  assign o = ^{p,l};
endmodule
