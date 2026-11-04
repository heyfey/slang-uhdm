// § classValueParamIntSigned202
package p;
  class c #(parameter int signed W = -1, int unsigned U = 3, parameter int K = 2);
    localparam int L = W + U;
    logic [K-1:0] v;
  endclass
  class d #(parameter integer I = 5, parameter shortint S = 1, int J = 7);
  endclass
endpackage
module v01; p::c #(2, 4, 3) h; p::d g; endmodule
