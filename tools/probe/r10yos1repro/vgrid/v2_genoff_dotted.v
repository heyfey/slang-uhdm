module \a.b.C (input wire a, output wire b);
  assign b = ~a;
endmodule

module plaintop #(parameter SEL = 0) (input wire x, output wire y);
  generate
    if (SEL) begin : g1
      \a.b.C u (.a(x), .b(y));
    end
    else begin : g2
      assign y = x;
    end
  endgenerate
endmodule
