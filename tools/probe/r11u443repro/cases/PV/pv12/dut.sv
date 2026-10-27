// § foreachPackedRefDeclTs443
module top;
logic [7:0] v;
if (1) begin : g
  initial foreach (v[i]) v[i] = 1'b0;
end
endmodule
