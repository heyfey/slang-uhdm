// § loneVarDeclStmtDropped401
module top;
  initial begin
    int q = 4;
  end
  always @* begin : nb
    logic z = 1'b1;
  end
endmodule
