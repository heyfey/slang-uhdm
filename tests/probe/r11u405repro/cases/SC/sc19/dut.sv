// § castSizeGenFence405
module top #(parameter n = 4, parameter w = $clog2(n)) (input logic [7:0] i, output logic [7:0] o, output logic [7:0] p);
  if (n > 1) begin : g
    assign o = w ' (i);
  end
  assign p = w'(i + 1);
endmodule
