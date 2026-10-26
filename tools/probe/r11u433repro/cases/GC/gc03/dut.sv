// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, z);
  logic [4:0] x;
  if (W > 1) begin: g
    if (W < 9) begin: h
      assign y = $bits(x) + W;
    end
  end else begin: e
    assign y = 0;
  end
  case (W)
    2: begin: c2
      assign z = W << 3;
    end
    default: begin: cd
      assign z = 1;
    end
  endcase
endmodule
