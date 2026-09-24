// LAW 1's MODULE-SCOPE face (R2): must be UNTOUCHED by the patch (the gate
// is inside emitGenScopes).
module top(input logic [31:0] a, output logic [31:0] arr[2]);
  assign arr = '{a, a};
endmodule
