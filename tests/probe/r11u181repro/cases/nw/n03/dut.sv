// § newLhsBitSelAtIndex181 — controls in a class method: a handle assigned to an array element, a plain handle new, a dynamic array new and an element write
class R; int a; endclass
class E;
  R rs [4];
  R h;
  int d [];
  function void build(int k);
    h = new;
    rs[k] = h;
    d = new[4];
    d[k] = 1;
  endfunction
endclass
module top; initial begin E e = new; e.build(1); end endmodule
