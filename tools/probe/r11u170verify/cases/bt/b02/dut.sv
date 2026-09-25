// § bodyTypeParamDefaultBound160
module top (input logic clk, output logic [15:0] o);
  localparam type my_t = struct packed { logic [3:0] a; logic [3:0] b; };
  localparam type w_t = my_t;
  w_t [1:0] q;
  always_ff @(posedge clk) q <= '0;
  assign o = q;
endmodule
