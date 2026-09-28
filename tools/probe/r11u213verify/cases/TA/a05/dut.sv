// § tpArrayElemBindsDefDefault206
typedef logic [5:0] six_t;
module a05 #(parameter type t = six_t) (input t i, output t o [2]);
  t mem [0:3];
  for (genvar g = 0; g < 2; g++) begin : gg
    t loc [2];
    assign loc[g] = i;
    assign mem[g] = loc[g];
  end
  assign o[0] = mem[0];
  assign o[1] = mem[1];
endmodule
