// § defGenPathSel161 — the right side of a gen-if assignment: a concatenation of scope paths (CFC, not SEL)
module top(output wire [1:0] o);
  if (1) begin : A
    wire x = 1'b1;
    wire y = 1'b0;
    wire [1:0] z;
    if (1) begin : B
      assign A.z = {A.x, A.y};
    end
  end
  assign o = A.z;
endmodule
