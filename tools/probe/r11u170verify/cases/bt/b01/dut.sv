// § bodyTypeParamDefaultBound160
module top (input logic clk, output logic [15:0] o);
  localparam type my_t = union packed { logic [7:0] a; logic [7:0] b; };
  my_t [1:0] q;
  always_ff @(posedge clk) q <= '0;
  assign o = q;
endmodule
