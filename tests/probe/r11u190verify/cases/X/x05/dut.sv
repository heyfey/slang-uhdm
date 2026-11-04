// § classTpDefaultTsAtUse180 § classMethodLvIsProcess181 § newLhsBitSelAtIndex181 (r11u190 cross: a class method assigning through a type-parameter-typed array)
package pkg;
  class base_c;
    int x;
  endclass
  class holder #(type CB = base_c);
    CB arr [4];
    function void f(int i);
      arr[i] = null;
      arr[i + 1] = new;
      arr[i + 1].x = i;
    endfunction
  endclass
endpackage
module top;
  initial begin
    pkg::holder h = new;
    h.f(0);
  end
endmodule
