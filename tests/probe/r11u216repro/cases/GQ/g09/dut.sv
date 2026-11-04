// § genScopeRangeQueryFold216 — $high of a ranged parameter in a generate case, in an interface
interface ifc;
  parameter [4:1] a = 3;
  case (1)
    1: begin : g
      assign ccc = $high(a);
    end
  endcase
endinterface
module top();
  ifc u();
endmodule
