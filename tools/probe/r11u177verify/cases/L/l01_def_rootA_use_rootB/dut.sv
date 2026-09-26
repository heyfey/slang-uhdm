// § ppOutputLine166 § ppOutputCol166
module top(input logic [3:0] a, input logic [3:0] b, output logic [4:0] y, output logic z);
  assign y = `ADDQ(a, b); assign z = a[0];
endmodule
