// t7: a CLASS type parameter and a GEN-SCOPE re-pass of a type parameter
// whose default carries a symbolic bound.
module leaf #(parameter int LW = 3, parameter type GT = logic [LW-1:0])
  (input GT g, output logic o);
  assign o = ^g;
endmodule
class cls #(parameter int CW = 5, parameter type CT = logic [CW-1:0]);
  CT c;
endclass
module dut (output logic o);
  logic [1:0] t;
  for (genvar i = 0; i < 2; i++) begin : gb
    leaf #(.LW(i+2)) u (.g('0), .o(t[i]));
  end
  assign o = ^t;
endmodule
