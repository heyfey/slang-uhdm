// § caSelLhsBareDecNoAdjust144
module top(output logic [15:0] o);
  logic [15:0] v;
  localparam int K = 4;
  assign v[K*2 +: 4] = 17;
  assign v[K-1 -: 4] = 2;
  assign v[15:12] = 1;
  assign v[3:0] = 0;
  assign o = v;
endmodule
