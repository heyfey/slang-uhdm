// § castSizeGenFence405
module top #(parameter n = 4) (input logic [7:0] i, output logic [7:0] o, output logic [7:0] p);
  localparam w = $clog2(n);
  wire [7:0] t = w ' (i);
  assign o = t;
  assign p = w'(i + 1);
endmodule
