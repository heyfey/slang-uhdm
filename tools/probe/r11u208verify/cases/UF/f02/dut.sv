// § unitBoundFoldAtLeftOperand200
package p;
  localparam int W = 4;
  localparam [W*2*2-1:0] A = 3;
  localparam [(W+1)*2-1:0] B = 1;
endpackage
localparam [p::W*2-1:0] U = 8'h7;
localparam int V = p::W * 3 + 1;
module f02(output logic [31:0] o);
  assign o = p::A + p::B + U + V;
endmodule
