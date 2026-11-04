// § caSelLhsBareDecNoAdjust144
module top(output logic [7:0] o);
  logic [7:0] v;
  assign v[3:0] = 20;
  assign v[7:4] = 9;
  assign o = v;
endmodule
