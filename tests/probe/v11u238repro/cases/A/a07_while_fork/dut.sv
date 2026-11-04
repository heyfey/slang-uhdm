// § cloneForIncBindsHomeVar238
// the loop variable read in a while condition, a case item, a nested function call argument and a return
package p;
  function int pick(int v); return v + 1; endfunction
  function int h(int n);
    for (int j = 0; j < n; j = j + 1) begin
      int w;
      w = j;
      while (w > j - 2) w--;
      case (j)
        1: return pick(pick(j));
        default: ;
      endcase
    end
    return 0;
  endfunction
endpackage
package q;
  import p::*;
  function int qh(int n); return h(n); endfunction
endpackage
module top;
  int r;
  initial r = q::qh(3);
endmodule
