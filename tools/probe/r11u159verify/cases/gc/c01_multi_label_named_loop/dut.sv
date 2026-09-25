// § genCaseItemUnnamed152
module GOOD();
endmodule
module top();
  parameter int S = 2;
  case (S)
    1, 2: begin: tag
      for (genvar i = 0; i < 2; i++) begin : l
        GOOD u();
      end
    end
    default: begin : d
      GOOD v();
    end
  endcase
endmodule
