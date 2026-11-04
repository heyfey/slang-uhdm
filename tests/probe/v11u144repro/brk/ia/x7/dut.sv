// § caSelLhsBareDecNoAdjust144
module sub(output logic [7:0] q);
  assign q[0] = 1;
  assign q[7:1] = 200;
endmodule
module top(output logic [7:0] o);
  logic [7:0] v;
  sub u(.q(v));
  assign o = v;
endmodule
