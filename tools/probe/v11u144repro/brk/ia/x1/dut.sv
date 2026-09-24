// § caSelLhsBareDecNoAdjust144
module top(output logic [31:0] o);
  logic [3:0][7:0] a;
  assign a[1] = 300;
  assign a[0] = 5;
  assign a[3:2] = 0;
  assign o = a;
endmodule
