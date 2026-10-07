// § scopedCallPrefixEndsAtColons270
package p;
  class reg_t #(type T = int);
    static function T create(string n, int x);
      return null;
    endfunction
  endclass
  class info;
    typedef reg_t#(info) type_id;
  endclass
endpackage
interface vif;
  import p::*;
  info arr[$];
  function void mk(string a);
    arr[arr.size() - 1] = info::type_id::
      create($sformatf("p_%s", a), 0);
    arr[0] = info::type_id::create(a, 0);
  endfunction
endinterface
module top;
  vif i();
endmodule
