// § vlogEnumBaseKwSpan235
module top(output [2:0] o);
  typedef enum logic signed [2:0] {A=-1, B=0} es_t;
  es_t x;
  assign o = x;
endmodule
