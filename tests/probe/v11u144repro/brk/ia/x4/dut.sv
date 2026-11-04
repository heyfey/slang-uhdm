// § caSelLhsBareDecNoAdjust144
module top(output logic [7:0] o);
  logic [7:0] v;
  for (genvar i = 0; i < 8; i++) begin : g
    assign v[i] = 1;
  end
  assign o = v;
endmodule
