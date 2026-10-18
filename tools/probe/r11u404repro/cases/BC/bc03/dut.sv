// § subrBuiltinClassArrElemUnsup404
class C; int x; endclass
module top ();
  task automatic t1 (int N);
    C c1[] = new [N];
    C c2[$];
    C c3;
    process p4;
    process p5[3];
  endtask
  function void f1();
    process p6[];
  endfunction
endmodule
