// § genCaAddParamIntCt435
module top #(parameter W = 4'd2) ();
  logic [7:0] y;
  case (W)
    2: begin: g
      assign y = W + 1;
    end
    default: begin: h
      assign y = 0;
    end
  endcase
endmodule
