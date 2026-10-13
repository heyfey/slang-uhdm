// § modConnIdxNestedNames317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top #(parameter logic [1:0] K = 2'b01) (input logic [3:0] ck, input logic a, output logic o);
  child c (.d(ck[K[0]] | a), .q(o));
endmodule
