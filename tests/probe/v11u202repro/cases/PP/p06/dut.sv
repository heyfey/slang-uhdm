// § defPortPackedTsKeepsWholeSpan200
module p06 #(parameter NA = 3, parameter DW = 2) (
  input  [NA-1:0]
         [DW-1:0] alert_class_i,
  input  logic [NA-1:0][DW-1:0] b,
  output [NA-1:0] [DW-1:0] o
);
  assign o = alert_class_i | b;
endmodule
