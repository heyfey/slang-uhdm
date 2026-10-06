// § cloneTdSpecDeepCopy269
module top;
  class obj; endclass
  class reg_c #(type T = obj, string N = "x"); endclass
  class c1 extends obj; typedef reg_c #(c1, "c1") tid; endclass
  class c2 extends obj; typedef reg_c #(c2, "c2") tid; endclass
  c2 h;
endmodule
