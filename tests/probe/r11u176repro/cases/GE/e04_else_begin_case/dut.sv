// § genElseBeginIfDepth176
module dut(input a, b, output c);
  parameter p = 2;
  if (p == 1) begin
    and g0(c, a, b);
  end else begin
    case (p)
      2: begin xor g1(c, a, b); end
      default: begin or g2(c, a, b); end
    endcase
  end
endmodule
