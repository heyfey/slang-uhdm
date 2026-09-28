// § tpArrayElemBindsDefDefault206
module a03 #(parameter type t = int) (input t i, output t o);
  t m [4];
  t d [1:0][3];
  always_comb begin
    m[0] = i;
    d[1][2] = m[0];
  end
  assign o = d[1][2];
endmodule
