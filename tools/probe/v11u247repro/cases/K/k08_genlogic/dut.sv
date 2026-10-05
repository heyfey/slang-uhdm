// § anonAggElemKeywordTs247
typedef logic [3:0] gb_t [2];
module top(input logic [3:0] a, output logic [3:0] o2);
  generate if (1) begin : g
    gb_t z;
    assign z[0] = a; assign z[1] = ~a;
    assign o2 = z[0] ^ z[1];
  end endgenerate
endmodule
