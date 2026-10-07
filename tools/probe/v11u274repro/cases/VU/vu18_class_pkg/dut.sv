// § pkgElabUnaryFoldOpSpan274
package pk;
  parameter int A = -3;
  class c #(parameter int Q = -4);
    localparam int R = -5;
    function int f(); return Q + R + A; endfunction
  endclass
endpackage
module dut(output int o); assign o = pk::A; endmodule
