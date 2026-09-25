// § genCaseItemUnnamed152
module top(output logic [1:0] o);
  parameter int S = 0;
  case (S)
    0: begin : c0
      for (genvar j = 0; j < 2; j++) begin : l
        assign o[j] = 1'b1;
      end
    end
    default: assign o = '0;
  endcase
endmodule
