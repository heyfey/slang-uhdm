// § classTpDefaultTsAtUse180 § classTpFormalMovesTs180 (r11u190: a specialization overriding the default beside the default specialization, both constructed in a module)
package pkg;
  class base_c;
  endclass
  class other_c;
  endclass
  class holder #(type CB = base_c);
    CB m;
    CB q[$];
    function void f(CB x);
      m = x;
      q.push_back(x);
    endfunction
  endclass
endpackage
module top;
  pkg::holder #(pkg::other_c) h1;
  pkg::holder h2;
  initial begin
    h1 = new;
    h2 = new;
  end
endmodule
