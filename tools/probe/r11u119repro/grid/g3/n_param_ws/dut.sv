module top #(parameter int P = 4     , parameter logic [7:0] Q = 8'hA5     ) (input logic [7:0] b, output logic [7:0] y);
  localparam int L = P     + 2;
  assign y = b + L[7:0] + Q;
endmodule
