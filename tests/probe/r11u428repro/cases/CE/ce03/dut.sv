// § synOneBitXUpper428
module top(input [3:0] a, output [3:0] o);
  for (genvar i = 0; i < 4; i++) begin: g
    assign o[i] = (a[i] === 1'bz) ? 1'bx : a[i];
  end
endmodule
