// § pkgVarLvalueScopeSep292
package p; int q; int arr[4]; endpackage
program prg;
  class c;
    task t();
      fork p::q = 1; join_none
      foreach (p::arr[i]) p::arr[i] = i;
      p::q <= 2;
    endtask
  endclass
  initial p::q = 3;
endprogram
module top; endmodule
