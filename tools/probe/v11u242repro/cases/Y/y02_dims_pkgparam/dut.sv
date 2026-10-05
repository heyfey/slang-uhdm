// § impArrParamTsOwnRanges242
// The array bound written through a package parameter and an expression, the array read in constant slots of the importer: a replication count, a part-select bound, a dimension bound, $size in a generate-for bound.
package hp;
  parameter int N = 3;
  parameter int T [N] = '{2, 3, 4};
  parameter int U [N-1:0] = '{5, 6, 7};
endpackage
module core import hp::*; (input logic [15:0] a, output logic [T[0]-1:0] o, output logic [7:0] r);
  assign o = a[T[0]-1:0];
  assign r = {T[1]{a[1:0]}} | a[U[2]:0];
  for (genvar g = 0; g < $size(T); g++) begin : gl
    logic [T[g]-1:0] w;
    assign w = a[g +: T[g]];
  end
endmodule
module top (input logic [15:0] a, output logic [1:0] o, output logic [7:0] r);
  core u (.a(a), .o(o), .r(r));
endmodule
