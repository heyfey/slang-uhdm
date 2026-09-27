// § pkgParamElabCaSharesDefFold183 (control: a module parameter keeps its own fold)
module m #(parameter logic [15:0] X = 16'h12) (output int a);
   assign a = X;
endmodule
module top(output int o);
   m u(.a(o));
endmodule
