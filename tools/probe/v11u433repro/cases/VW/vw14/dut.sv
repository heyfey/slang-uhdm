// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  wire [7:0] y;
  case (W)
    2: begin: c2
      assign y = W << 3;
    end
    default: begin: cd
      assign y = 0;
    end
  endcase
endmodule
