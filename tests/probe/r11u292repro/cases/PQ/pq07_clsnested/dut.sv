// § pkgVarLvalueScopeSep292
package q;
  int qi = 3;
endpackage
package p;
  class c;
    function void h(int k);
      if (k > 0) begin
        q::qi = k;
      end
      for (int i = 0; i < 2; i++) q::qi += i;
    endfunction
  endclass
endpackage
module top; p::c o = new(); endmodule
