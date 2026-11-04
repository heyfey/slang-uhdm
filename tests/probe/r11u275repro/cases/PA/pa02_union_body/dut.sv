// § tpPackedArrCaUnparent275 — anonymous packed union with dimensions, a body net assigned
module dut #(parameter type T = union packed { logic [1:0] a; logic [1:0] b; } [3:0]) (input logic [7:0] i, output logic [7:0] o);
  T x;
  assign x = i;
  assign o = x;
endmodule
