// § genCaseItemProcNoFull416
module top #(parameter W = 3);
  typedef struct packed { logic [3:0] a; logic b; } s_t;
  s_t s;
  case (W)
    1: begin : g end
    default:
      always @* begin s.a = 4'd1; s.b = s.a[0]; end
  endcase
endmodule
