// § methArgPathIdxAtHierPath270
package p;
  class info;
    function string get_name(); return "n"; endfunction
  endclass
endpackage
interface vif;
  import p::*;
  info sva_info[$];
  function bit exists(string a, string b);
    return 1;
  endfunction
endinterface
package q;
  import p::*;
  class w;
    virtual vif v;
    function void t(int index);
      if (!v.exists(v.sva_info[index].get_name(), v.sva_info[index].get_name())) begin
      end
    endfunction
  endclass
endpackage
module top;
endmodule
