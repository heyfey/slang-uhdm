// § tpCastUseBindsDefDefault206
typedef logic [4:0] nib_t;
module c02 #(parameter type t = nib_t) (input logic clk, input logic s, output t o);
  t [3:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    always @(posedge clk) begin
      if (s) x[i] <= t'(i);
      else x[i] <= t'(x[i] + t'(1));
    end
    initial x[i+2] = t'(0);
  end
  assign o = x[0];
endmodule
