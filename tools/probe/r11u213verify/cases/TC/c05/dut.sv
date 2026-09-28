// § tpCastUseBindsDefDefault206
typedef struct packed { logic [1:0] hi; logic [2:0] lo; } pk_t;
module c05 #(parameter type t = pk_t) (input logic [1:0] s, output t o);
  t [1:0][1:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    case (i)
      0: begin : c0
        assign x[i][0] = s[0] ? t'(5'h11) : t'(5'h02);
      end
      default: begin : cd
        assign x[i][0] = t'({s, 3'b101});
      end
    endcase
    assign x[i][1] = t'(i);
  end
  assign o = x[1][0];
endmodule
