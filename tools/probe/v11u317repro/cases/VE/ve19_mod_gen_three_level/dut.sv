// § modConnIdxNestedNamesGen317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] ck, input logic [1:0] k, input logic [1:0] j, input logic a, output logic o);
  if (1) begin : g
    child c (.d(ck[k[j[0]]] | a), .q(o));
  end
endmodule
