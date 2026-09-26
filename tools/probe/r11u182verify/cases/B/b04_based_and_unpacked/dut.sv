// § boundLitWrittenDigits172
module dut (input logic [7:0] a, output logic [7:0] o);
  logic ['d7:0] x;
  logic [8'd7:0] y;
  logic [3:0] u [00:01];
  logic [1_0:03] z;
  parameter int Q [00:1] = '{1, 2};
  assign x = a;
  assign y = x;
  assign u[0] = y[3:0];
  assign z = y;
  assign o = y;
endmodule
