module ch(input logic [15:0] a, input logic [15:0] b, input logic p, output logic [33:0] o);
  logic sa, sb;
  logic signed [33:0] res;
  if (1) begin : gb
    logic [15:0] oa;
    logic [15:0] ob;
    always_comb begin
      oa = a; ob = b; sa = p; sb = p;
    end
    assign res = $signed({sa, oa}) * $signed({sb, ob});
  end
  assign o = res;
endmodule
module top(input logic [15:0] a, input logic [15:0] b, input logic p, output logic [33:0] o);
  ch u_c(.a(a), .b(b), .p(p), .o(o));
endmodule
