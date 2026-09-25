// ARR: unpacked_array_shift_ff's shape: the whole write sits in a SIBLING
// begin of the select writes (the scope chain never meets them).
module top(input logic clk, input logic rst, input logic [3:0] din, output logic [3:0] dout);
  logic [3:0] arr [3:0];
  always_ff @(posedge clk, posedge rst)
    if (rst) begin
      arr <= '{default: '0};
    end else begin
      arr[0] <= din;
      arr[3:1] <= arr[2:0];
    end
  assign dout = arr[3];
endmodule
