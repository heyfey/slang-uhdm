// § hpDotWsTrimmed167 § defGenPathSel161 — blanks around the dot of a continuous-assignment target inside a gen-if block
module top (output wire o);
  if (1) begin : A
    wire x;
    if (1) begin : B
      assign A . x = 1'b1;
    end
  end
  assign o = A.x;
endmodule
