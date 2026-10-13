// § modConnIdxNestedNamesGen317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] ck, input logic [1:0] k, input logic a, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    child c (.d(ck[k[i]] | a), .q(o[i]));
  end
endmodule
