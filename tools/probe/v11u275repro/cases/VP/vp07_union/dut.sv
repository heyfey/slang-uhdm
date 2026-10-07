// § tpPackedArrCaUnparent275 — an anonymous packed union with dimensions in a body net
module dut #(parameter type T = union packed { logic [1:0] a; logic [1:0] b; } [1:0]) (input logic [3:0] i, output logic [3:0] o);
  T w;
  assign w = i;
  assign o = w;
endmodule
