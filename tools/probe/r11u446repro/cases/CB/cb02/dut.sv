// § clsBodyCallBindsHomeTopTf446
package p;
  function int rep(int v);
    return v + 1;
  endfunction
  task automatic tk(int v);
    $display(v);
  endtask
endpackage
package q;
  import p::*;
  class C;
    task run();
      tk(rep(2));
    endtask
  endclass
endpackage
module top;
  import q::*;
  C c;
endmodule
