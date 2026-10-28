// § ifcTaskFixupWalksAllStmts454
interface bfm(output logic [7:0] a);
  logic [3:0] cnt;
  function automatic int f(int x);
    if (x > 2) begin
      cnt = 4'd1;
      return a;
    end
    unique case (x)
      1: cnt = 4'd2;
      default: ;
    endcase
    return 0;
  endfunction
endinterface
module top;
  logic [7:0] a;
  bfm u(.a(a));
endmodule
