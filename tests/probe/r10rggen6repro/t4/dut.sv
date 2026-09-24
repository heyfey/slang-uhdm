module m #(
  parameter int ADDRESS_WIDTH = 8,
  parameter bit [ADDRESS_WIDTH-1:0] OFFSET_ADDRESS = '0,
  parameter int WORDS = 2
)(output logic o);
  genvar g;
  generate
    for (g = 0; g < WORDS; ++g) begin : gd
      localparam bit [ADDRESS_WIDTH-1:0] START_ADDRESS = OFFSET_ADDRESS
                                                       + ADDRESS_WIDTH'(4 * g);
      localparam int PLAIN_LP = g + 1;
    end
  endgenerate
  assign o = 1'b0;
endmodule

module top(output logic o);
  m #(.ADDRESS_WIDTH(8), .WORDS(2)) u(o);
endmodule
