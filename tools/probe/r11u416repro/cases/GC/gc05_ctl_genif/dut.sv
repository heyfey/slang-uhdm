// § genCaseItemProcNoFull416
module top #(parameter W = 3);
  if (W == 1) begin : g
  end else begin : h
    initial begin $display("bad"); end
  end
endmodule
