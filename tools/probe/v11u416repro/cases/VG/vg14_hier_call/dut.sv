// § genCaseItemProcNoFull416
module top #(parameter W = 3);
  int r;
  function int f(int v); return v; endfunction
  case (W)
    1: begin : g end
    default:
      initial begin r = top.f(2); end
  endcase
endmodule
