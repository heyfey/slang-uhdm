// § doWhileSyntaxFromCond181 (v11u181 break: do-while bodies declaring locals in a parameterized class: nested do-while, a task, a begin with two locals)
package p;
  typedef struct { int a; } SS;
  class G #(type T = int);
    int n;
    function void f(int k);
      do begin SS b; int c; b.a = k; c = b.a; k--; end while (k > 0);
      do begin
        int d;
        do begin int e; e = d; d++; end while (d < 3);
      end while (n > 0);
    endfunction
    task t(); do begin T x; n--; end while (n > 0); endtask
  endclass
endpackage
module top; endmodule
