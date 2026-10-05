// § genLpSysCallArgName239
// a parameter keyword inside a generate block, $high and $clog2 of an enum constant, nested if in for
package p;
  typedef enum int {E0 = 5, E1 = 9} e_t;
endpackage
module top import p::*; #(parameter int N = 4) (input logic [N-1:0] r, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : gf
    if (i == 0) begin : gi
      parameter int H = $high(r);
      localparam int C = $clog2(E1);
      assign o[i] = r[0] ^ (H > C);
    end else begin : ge
      assign o[i] = r[1];
    end
  end
endmodule
