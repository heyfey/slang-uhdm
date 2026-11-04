// § bodyTypeParamDefaultBound160
module top (input logic clk, input logic [7:0] d, output logic [7:0] o);
  localparam type my_t = struct packed { logic [3:0] a; logic [3:0] b; };
  my_t s;
  always_ff @(posedge clk) s <= d;
  assign o = s;
endmodule
