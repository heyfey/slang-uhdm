// § caSelLhsBareDecNoAdjust144
module top(output logic [7:0] o, output logic [7:0] p);
  logic [7:0] m [2];
  wire [7:0] w;
  assign m[1][3:0] = 20;
  assign m[1][7:4] = 1;
  assign m[0] = 300;
  assign w[3:0] = 300;
  assign w[7:4] = 0;
  assign o = m[1] ^ m[0];
  assign p = w;
endmodule
