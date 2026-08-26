// r10earl98 g0 -- THE HEAD'S OWN SHAPE.
// A gen-scope cont_assign whose LHS is a gen-LOCAL whose NAME also exists as a
// net/variable of an ANCESTOR module instance (Earlgrey: prim_fifo_sync's
// `fifo_empty` vs hmac's).  The twin `loc_full` is declared NOWHERE else.
module leaf98 #(parameter int W = 2) (input logic clk, input logic [W-1:0] a,
                                      output logic o);
  if (W > 0) begin : gen_b
    logic [W-1:0] p1, p2;
    logic loc_empty;   // SHADOWED at d1 and d2
    logic loc_full;    // shadowed NOWHERE
    assign loc_empty = (p1 == p2);
    assign loc_full  = (p1 != p2);
    assign o = loc_empty & loc_full;
    always_ff @(posedge clk) begin
      p1 <= a;
      p2 <= p1;
    end
  end
endmodule

module mid98 (input logic clk, input logic [1:0] a, output logic o);
  leaf98 #(.W(2)) u_leaf (.clk(clk), .a(a), .o(o));
endmodule

module g0_head98 (input logic clk, input logic [1:0] a, output logic o);
  logic loc_empty;              // the ANCESTOR name (d2 from the gen scope)
  assign loc_empty = 1'b0;
  mid98 u_mid (.clk(clk), .a(a), .o(o));
endmodule
