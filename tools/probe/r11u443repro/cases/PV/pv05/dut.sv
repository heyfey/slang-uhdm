// § foreachPackedRefDeclTs443
module top;
task automatic t(); logic [3:0] lv; foreach (lv[i]) lv[i] = 1'b1; endtask
initial t();
endmodule
