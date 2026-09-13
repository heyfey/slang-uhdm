module top(input logic [15:0] a, input logic [15:0] b, output logic [33:0] o);
  logic sa, sb;
  logic signed [33:0] res;
  if (1) begin : gb
    logic [15:0] oa;
    logic [15:0] ob;
    always_comb begin
      oa = a; ob = b; sa = 1'b0; sb = 1'b0;
    end
    assign res = {sa, oa} * {sb, ob};
  end
  assign o = res;
endmodule
