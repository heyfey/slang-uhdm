// § defGenPathSel161 — a concatenation target of two scope paths in a gen-if block
module top(output wire [1:0] o);
  if (1) begin : A
    wire x;
    wire y;
    if (1) begin : B
      assign {A.x, A.y} = 2'b10;
    end
  end
  assign o = {A.x, A.y};
endmodule
