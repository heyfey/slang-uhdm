// § genGateTermGenNetBind418
module m (input [1:0] a, output [1:0] s);
  for (genvar i = 0; i < 2; i = i + 1) begin : o
    wire t;
    if (i == 0) begin : z
      and g1 (t, a[i], a[1]);
    end else begin : nz
      or g2 (t, a[i], a[0]);
    end
    assign s[i] = t;
  end
endmodule
