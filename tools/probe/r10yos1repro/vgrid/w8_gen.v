module taken (input wire a, output wire b);
  assign b = a;
endmodule

module nottaken (input wire a, output wire b);
  assign b = ~a;
endmodule

module \a.b.C #(parameter SEL = 1) (input wire x, output wire y);
  generate
    if (SEL) begin : g1
      taken t1 (.a(x), .b(y));
    end
    else begin : g2
      nottaken n1 (.a(x), .b(y));
    end
  endgenerate
endmodule
