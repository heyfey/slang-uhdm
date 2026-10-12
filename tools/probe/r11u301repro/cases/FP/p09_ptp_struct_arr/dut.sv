// § caFillPackedAggElabSharesDef301
module m #(parameter type T = struct packed { logic [3:0] a; logic [3:0] b; }) (output logic [15:0] o);
  T [1:0] q;
  assign q = '1;
  assign o = q;
endmodule
