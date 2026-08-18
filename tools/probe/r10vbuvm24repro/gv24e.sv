// r10vbuvm24repro/gv24e.sv — NEGATIVE CONTROL: a FOREACH index list with an
// empty slot (the `SynthForeach` corpus shape).  MEASUREMENT ONLY.
module fev24;
  int B [2][2][2][2];
  int s;
  initial begin
    foreach (B[q,,r]) s = s + B[q][0][r][0];
  end
endmodule
