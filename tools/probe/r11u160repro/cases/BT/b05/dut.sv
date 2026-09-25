// § bodyTypeParamDefaultBound160
module top (input logic clk, input logic [15:0] d, output logic [15:0] o);
  localparam type u_t = union packed { logic [15:0] a; logic [15:0] b; };
  u_t [0:0] q;
  assign q = d;
  assign o = q;
endmodule
