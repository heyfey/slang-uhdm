// § arrQueryFoldAtBound158
package p; parameter logic [4:1] a = 0; parameter int H = $high(a); endpackage
module dut (output int o);
  assign o = p::H;
endmodule
