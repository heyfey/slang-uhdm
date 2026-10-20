// § unitVarNestedScopeAbstain418v
logic [1:0] g = 2'b10;
module top (output logic [1:0] o);
  case (1)
    1: begin : c assign o = g; end
    default: begin : d assign o = 2'b0; end
  endcase
endmodule
