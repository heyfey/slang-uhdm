// § impArrParamTsOwnRanges242
// Control: a package importing the array parameter (a package listing, no law) and a module
// importing both packages.
package hp;
  parameter int A [4] = '{1, 2, 3, 4};
endpackage
package q;
  import hp::*;
  localparam int S = 5;
  function automatic int f(int k); return A[k]; endfunction
endpackage
module top import q::*; import hp::*; (input logic [1:0] k, output logic [31:0] o);
  assign o = S + A[k];
endmodule
