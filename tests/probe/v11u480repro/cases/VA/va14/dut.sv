// § fixArrLocalNamedAggElemTs480 (enum element, ascending range, case statement)
module top;
  typedef enum logic [1:0] { S0, S1, S2 } st_t;
  function automatic logic [1:0] f(input logic [1:0] n);
    st_t q[0:3];
    q[1] = st_t'(n);
    case (q[1])
      S0: return 2'd0;
      S1: return 2'd1;
      default: return 2'd2;
    endcase
  endfunction
  logic [1:0] x;
  assign x = f(2'd1);
endmodule
