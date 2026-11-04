// § cloneArrTsHomeElabFirst253
package p;
  task automatic t(string a);
    fork
      begin
        string acts[$];
        acts.push_back(a);
        foreach (acts[i]) acts[i] = a;
      end
    join
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
