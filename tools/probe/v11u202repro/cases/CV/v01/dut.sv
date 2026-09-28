// § classValueParamIntSigned202
package p;
  class c #(parameter int signed W = 4, parameter int unsigned U = 2, int X = 1);
    localparam int L = W + 1;
    parameter int B = 3;
    logic [W-1:0] v;
  endclass
  c #(5, 3, 2) h;
endpackage
module v01; endmodule
