// § foreachPackedRefDeclTs443
module top;
logic [3:0] v; logic [3:0] w;
assign w = v;
initial foreach (w[i]) $display(w[i]);
endmodule
