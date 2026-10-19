// § castSizeGenFence405
module top #(parameter n = 4, parameter w = $clog2(n)) (input logic [7:0] i, output logic [7:0] o);
  if (n > 1) begin : g
    assign o = w ' (i);
  end
endmodule
