// § rootElemAtNextTok186: $root paths read in continuous assignments of a NESTED generate scope (if inside a named block) and of a generate-for body
module top;
  logic [3:0] q;
  logic [1:0] s;
  sub u ();
endmodule
module sub;
  logic [3:0] w;
  logic [1:0] x [2];
  if (1) begin : ga
    if (1) begin : gb
      assign w = $root.top.q;
    end
  end
  for (genvar i = 0; i < 2; i++) begin : gl
    assign x[i] = $root.top.s;
  end
endmodule
