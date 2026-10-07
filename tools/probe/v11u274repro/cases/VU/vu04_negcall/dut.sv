// § pkgElabUnaryFoldOpSpan274
package pk;
  function automatic int f(int x); return x * 2; endfunction
  parameter int A = -f(2);
  parameter int C = -$clog2(8);
endpackage
module dut(output int o, output int c); assign o = pk::A; assign c = pk::C; endmodule
