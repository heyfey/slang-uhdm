// § caFillPackedAggElabSharesDef301
module c(output logic [15:0] o);
  localparam type T = struct packed { logic [3:0] a; logic [3:0] b; };
  T [1:0] q;
  assign q = '1;
  assign o = q;
endmodule
module m(output logic [15:0] o);
  c u(.o(o));
endmodule
