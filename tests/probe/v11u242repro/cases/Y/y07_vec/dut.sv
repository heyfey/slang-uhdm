// § impArrParamTsOwnRanges242
// A logic-vector array [0:3] and a bit array [3:0] imported by a module with a parameter port list; variable and constant index.
package hp;
  parameter logic [7:0] B [0:3] = '{8'h1, 8'h2, 8'h3, 8'h4};
  localparam bit [3:0] C [3:0] = '{4'h1, 4'h2, 4'h3, 4'h4};
  parameter int A [4] = '{1, 2, 3, 4};
endpackage
module core import hp::*; #(parameter int P = 1) (input logic [1:0] i, output logic [7:0] o, output int a, output logic [3:0] c);
  assign o = B[i];
  assign a = A[i];
  assign c = C[2];
endmodule
module top (input logic [1:0] i, output logic [7:0] o, output int a, output logic [3:0] c);
  core u (.i(i), .o(o), .a(a), .c(c));
endmodule
