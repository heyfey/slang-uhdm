// § anonAggElemKeywordTs247
typedef bit [1:0] pr_t [4];
module top(input logic [1:0] a, output logic [1:0] o);
  pr_t t;
  assign t[0] = a;
  assign t[1] = ~a;
  assign o = t[a[0]];
endmodule
