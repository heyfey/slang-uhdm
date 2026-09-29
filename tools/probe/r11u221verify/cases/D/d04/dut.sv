// § incDecOperandKeepsLvalueForm215 — inc/dec of a package-qualified variable (control: not a member path), of a $unit class handle's member in a $unit function, and in a do-while and a repeat condition
package p;
  int pv;
endpackage
class uc; int n; int arr[4]; endclass
function automatic int uf(uc h);
  int r;
  r = h.arr[h.n++];
  do r++; while (h.n-- > 0);
  repeat (h.n++) r--;
  p::pv++;
  return r + (++h.n);
endfunction
module m;
endmodule
