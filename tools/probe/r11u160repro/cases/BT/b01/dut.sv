// § bodyTypeParamDefaultBound160
module top (input logic clk, output logic [63:0] sum);
  localparam type my_t = struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; };
  my_t        scalar_sig;
  my_t [2:0]  arr;
  assign scalar_sig = '0;
  assign arr        = '0;
  assign sum = scalar_sig.a + arr[0].a + arr[2].b;
endmodule
