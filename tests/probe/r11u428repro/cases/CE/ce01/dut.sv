// § synCaseEqXnorOps428
module top(input [3:0] a, b, output [3:0] o);
  for (genvar i = 0; i < 4; i++) begin: g
    assign o[i] = (a[i] === 1'bx) ? b[i] : (a[i] !== 1'b0);
  end
endmodule
