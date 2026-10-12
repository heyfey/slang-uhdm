// § caFillPackedAggElabSharesDef301
module m(output logic [15:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t [1:0] q;
  if (1) begin : g
    assign q = '1;
  end
  assign o = q;
endmodule
