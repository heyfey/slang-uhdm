// § lpBoundOperandKeepsBase145v
module dut #(parameter int WIDTH = 8, parameter int BUS_WIDTH = 32) (input logic [WIDTH-1:0] i_address, output logic o);
  localparam int LSB = $clog2(BUS_WIDTH) - 3;
  if (1) begin : g_address_matcher
    assign o = i_address[WIDTH-1:LSB] == 6'd1;
  end
endmodule
