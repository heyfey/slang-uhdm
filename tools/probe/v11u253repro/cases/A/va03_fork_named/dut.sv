// § cloneArrTsHomeElabFirst253 (a named fork's local)
package p;
  task automatic t(int k);
    fork : fk
      begin
        int v[$];
        v.push_back(k);
        foreach (v[i]) v[i]++;
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
