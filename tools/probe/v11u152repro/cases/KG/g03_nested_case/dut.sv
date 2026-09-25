// § genCaseItemUnnamed152
module top(output logic o);
  parameter int S = 1;
  parameter int T = 0;
  case (S)
    1: begin : outer
      case (T)
        0: begin : inner
          wire w = 1'b1;
          assign o = w;
        end
        default: assign o = 1'b0;
      endcase
    end
    default: assign o = 1'b0;
  endcase
endmodule
