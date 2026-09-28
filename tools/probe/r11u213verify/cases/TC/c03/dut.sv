// § tpCastUseBindsDefDefault206 § tpArrayElemBindsDefDefault206 (an int default: casts in a generate-scope function body with a local of the type and in an always block; an unpacked array of the type)
module c03 #(parameter type t = int) (input logic s, output t o, output t p);
  t x [2];
  t y [2];
  for (genvar i = 0; i < 2; i++) begin : g
    function automatic t f(input logic b, input int k);
      t r;
      r = b ? t'(k + 5) : t'(-1);
      return r;
    endfunction
    assign x[i] = f(s, i);
    always_comb y[i] = s ? t'(i) : t'(2);
  end
  assign o = x[0] + x[1];
  assign p = y[1];
endmodule
