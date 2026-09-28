// § classValueParamIntSigned202
package p;
  class c #(parameter int W = 4);
    logic [W-1:0] v;
  endclass
endpackage
module p01; p::c #(8) h; endmodule
