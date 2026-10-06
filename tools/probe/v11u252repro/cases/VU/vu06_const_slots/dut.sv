// § dupImportSameValueKeeps252
package p;
parameter W = 6;
parameter N = 3;
parameter K = 2;
endpackage
import p::*;
module top(input logic [W-1:0] i, output logic [W-1:0] o, output logic [N-1:0] r, output logic [K-1:0] s);
  logic [7:0] mem [0:N-1];
  assign o = i;
  assign r = {N{i[0]}};
  assign s = i[1 +: K];
  localparam int LP = W * N;
  for (genvar g = 0; g < N; g++) begin : gl
    assign mem[g] = 8'(LP + g);
  end
endmodule
