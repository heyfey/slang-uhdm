module ch(input logic [15:0] a, input logic [15:0] b, input logic p, output logic [33:0] o);
  logic [33:0] q;
  if (1) begin : gb
    logic sa, sb;
    logic [15:0] oa;
    logic [15:0] ob;
    logic signed [33:0] res;
    always_comb begin
      oa = a; ob = b; sa = p; sb = p;
    end
    assign res = $signed({sa, oa}) * $signed({sb, ob});
    assign q = res;
  end
  assign o = q;
endmodule
module top(input logic [15:0] a, input logic [15:0] b, input logic p, output logic [33:0] o);
  ch u_c(.a(a), .b(b), .p(p), .o(o));
endmodule
