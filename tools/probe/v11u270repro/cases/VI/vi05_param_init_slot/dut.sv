// § insideSetParamFoldKeepsPa270
package up;
  parameter int A = 1;
  parameter int B = 2;
endpackage
module top #(parameter int W = 2) (output logic [3:0] o);
  import up::*;
  localparam bit L = W inside {A, B};
  localparam int N = (W inside {A, B}) ? 4 : 2;
  logic [N-1:0] v;
  assign o = {3'b0, L};
endmodule
