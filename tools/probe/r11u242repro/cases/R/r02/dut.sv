// § impArrParamTsOwnRanges242
// Two unpacked dimensions, an ascending range and a range bound by a package localparam,
// read with variable indices.
package hp;
  localparam int N = 3;
  parameter int A [2][3] = '{'{1, 2, 3}, '{4, 5, 6}};
  parameter int B [0:N-1] = '{7, 8, 9};
endpackage
module top import hp::*; (input logic i, input logic [1:0] j, output logic [31:0] o);
  assign o = A[i][j] + B[j];
endmodule
