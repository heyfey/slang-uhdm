package pk; parameter int unsigned P = 2; endpackage
module top import pk::*; (input logic [3:0] a, input logic s, output logic [1:0] y);
  assign y = s ? {a[P-1], a[P+1]} : {a[0], a[P*1]};
endmodule
