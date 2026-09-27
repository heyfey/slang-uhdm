// § withClauseCloseParenEnd183
package p;
class c; int id; endclass
class k;
  function int f();
    c a[$];
    c b[$];
    b = a.find(x) with (x.id > 1);
    return b.size();
  endfunction
endclass
endpackage
module top; endmodule
