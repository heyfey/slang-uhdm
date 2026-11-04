// § newLhsBitSelAtIndex181 (r11u190: a dynamic-array element given new[size expression] and a copy new[n](...) in a class method)
class C;
  int da [4][];
  function void build(int i, int n);
    da[i] = new[n * 2];
    da[i + 1] = new[n](da[i]);
  endfunction
endclass
module top;
  initial begin
    C c = new;
    c.build(0, 2);
  end
endmodule
