// ARR: asicworld_serial_crc's shape: bit writes, bit reads, and a whole read
// in the same nonblocking begin.
module top(input logic clk, input logic d, output logic [3:0] y);
  logic [3:0] lfsr;
  always @(posedge clk) begin
    lfsr[0] <= d ^ lfsr[3];
    lfsr[1] <= lfsr[0];
    lfsr[3:2] <= lfsr[2:1];
    y <= lfsr;
  end
endmodule
