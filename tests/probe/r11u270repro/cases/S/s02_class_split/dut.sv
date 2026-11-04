// § scopedCallPrefixEndsAtColons270
package p;
  class reg_t #(type T = int);
    static function T create(string n);
      return null;
    endfunction
  endclass
  class info;
    typedef reg_t#(info) type_id;
  endclass
  class user;
    info arr[$];
    function void mk(string a);
      arr[0] = info::type_id::
        create(a);
      arr[1] = info::type_id::create(a);
      arr[2] = info::type_id:: create(a);
    endfunction
  endclass
endpackage
module top;
endmodule
