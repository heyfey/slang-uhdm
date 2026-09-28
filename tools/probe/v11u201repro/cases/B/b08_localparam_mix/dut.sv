// § unitBoundFoldAtLeftOperand200
localparam W = 4;
localparam [W*2*2-1:0] A = 3;
localparam [(W)-1:0] B = 1;
localparam [W+W+W-1:0] C = 2;
localparam [2**3-1:0] D = 5;
localparam [W<<1:1] E = 6;
package p;
  localparam W = 4;
  localparam [W*2*2-1:0] A = 3;
  localparam [(W)-1:0] B = 1;
  localparam [2**3-1:0] D = 5;
  localparam [W<<1:1] E = 6;
endpackage
module top(output logic [31:0] o, output logic [31:0] o2);
  assign o = A + B + C + D + E;
  assign o2 = p::A + p::B + p::D + p::E;
endmodule
