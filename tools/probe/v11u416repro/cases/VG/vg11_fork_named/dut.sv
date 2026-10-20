// § genCaseItemProcNoFull416
module top #(parameter W = 3);
  logic [3:0] x;
  case (W)
    1: begin : g end
    default:
      initial begin
        fork : fk
          x = 1;
          x = 2;
        join
      end
  endcase
endmodule
