module top(input logic [31:0] a, output logic [31:0] o);
  localparam int LP = 3;
  if (LP > 2) begin : gb
    localparam int GP = LP * 2;
    if (1) begin : gc
      assign o = (GP == 6) ? GP : '0;
    end
  end
endmodule
