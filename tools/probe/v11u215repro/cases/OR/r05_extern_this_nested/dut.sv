// § opIdxRecvElemFollowsPath215 — an extern method body outside the class, this.-rooted receivers, a receiver call as another receiver's index and as a part-select bound
package p;
  class fld;
    function int get(); return 0; endfunction
  endclass
  class reg_c;
    fld fields[$];
    bit [7:0] v;
    extern function int f(int i);
    function int g(int i);
      int a;
      a = this.fields[i-1].get();
      a = fields[fields[i-1].get()].get();
      a = v[fields[i+1].get() +: 2];
      return a;
    endfunction
  endclass
  function int reg_c::f(int i);
    return fields[i-1].get();
  endfunction
endpackage
module m;
endmodule
