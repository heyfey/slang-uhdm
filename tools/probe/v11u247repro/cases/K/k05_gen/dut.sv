// § anonAggElemKeywordTs247
typedef bit [3:0] gb_t [2];
module sub #(parameter int N = 1)(input logic [3:0] a, output logic [3:0] o);
  gb_t t;
  assign t[0] = a;
  assign t[1] = a + N;
  assign o = t[1];
endmodule
module top(input logic [3:0] a, output logic [3:0] o, output logic [3:0] o2);
  sub #(2) u(.a(a), .o(o));
  generate if (1) begin : g
    gb_t z;
    assign z[0] = a; assign z[1] = ~a;
    assign o2 = z[0] ^ z[1];
  end endgenerate
endmodule
