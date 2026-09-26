// § genElseIfGateTermPath171
module dut(input a, b, output c);
  parameter p = 2, q = 4;
  if (p == 1)
    begin : u0
      and g1(c, a, b);
    end
  else if (p == 2) begin
    case (q)
      0, 1, 2:
        begin : u1
          xor g2(c, a, b);
        end
      default:
        begin : u1
          xnor g3(c, a, b);
        end
    endcase
    if (1)
      begin
        xnor g4(c, a, b);
      end
    if (1)
      begin : n5
        xnor g5(c, a, b);
      end
  end
endmodule
