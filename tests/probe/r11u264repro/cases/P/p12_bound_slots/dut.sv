// § elabParamRefSignedTsUnlocated264
module sub #(parameter int W = 4) (output logic [7:0] o);
  localparam int B = W;
  logic [B-1:0] r;
  localparam int R = {2{B[1:0]}};
  assign r = {B{1'b1}};
  assign o = {r, r[B-1 -: 2]} + R;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
