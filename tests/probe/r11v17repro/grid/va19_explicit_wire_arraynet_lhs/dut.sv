// LAW 1 with an EXPLICIT wire unpacked array.
module top(input logic [31:0] a, output logic [31:0] o);
  wire [31:0] arr[2];
  if (1) begin : gb
    assign arr = '{a, a};
  end
  assign o = arr[0];
endmodule
