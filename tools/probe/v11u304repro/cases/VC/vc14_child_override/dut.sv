// § genCaCastTdAliasScopedName304
module child #(parameter int W = 2) (input logic [7:0] a, output logic [W-1:0] y);
  typedef logic [W-1:0] idx_t;
  if (W > 1) begin : g
    assign y = idx_t'(a) + 1'b1;
  end
endmodule
module top (input logic [7:0] a, output logic [2:0] y, output logic [3:0] z);
  child #(.W(3)) u (.a(a), .y(y));
  child #(.W(4)) v (.a(a), .y(z));
endmodule
