// § impArrParamTsOwnRanges242
// The unpacked dimension inside a typedef (no dimension on the parameter itself), beside one with both, a string array and a real array.
package hp;
  typedef logic [7:0] arr_t [4];
  parameter arr_t A = '{8'h1, 8'h2, 8'h3, 8'h4};
  typedef logic [3:0] row_t [2];
  parameter row_t M [2] = '{'{4'h1, 4'h2}, '{4'h3, 4'h4}};
  parameter string S [2] = '{"a", "bc"};
  parameter real R [2] = '{1.0, 2.5};
endpackage
module core import hp::*; (input logic [1:0] i, output logic [7:0] o, output logic [3:0] m);
  assign o = A[i];
  assign m = M[i[0]][i[1]];
endmodule
module top (input logic [1:0] i, output logic [7:0] o, output logic [3:0] m);
  core u (.i(i), .o(o), .m(m));
endmodule
