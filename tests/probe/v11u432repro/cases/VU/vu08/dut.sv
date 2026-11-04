// § unitParamShadowDefBind432
localparam CF = 0;
module m(input clk, input [3:0] a, output logic o);
  localparam CF = 1;
  always_ff @(posedge clk) begin : blk
    o <= a[CF];
  end
  assert property (@(posedge clk) a[CF] |-> o);
endmodule
