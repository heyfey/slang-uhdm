module top(input logic clk, output logic [31:0] o);
  localparam type my_t = logic [7:0];
  my_t s;
  my_t [1:0] arr;
  assign s = '0;
  assign arr = '0;
  assign o = s + arr[0];
endmodule
