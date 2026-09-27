// § rootElemAtNextTok186 (a case-generate scope, a three-level path)
module top; mid m(); endmodule
module mid; logic [1:0] q; sub u(); endmodule
module sub;
  logic [1:0] w;
  case (1)
    1: begin : c assign w = $root.top.m.q; end
  endcase
endmodule
