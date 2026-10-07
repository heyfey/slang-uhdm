// § scopedCallPrefixEndsAtColons270
package p;
  class inner; int v; endclass
  class c;
    static inner obj;
    static function c create(); return null; endfunction
    typedef c type_id;
  endclass
endpackage
module top;
  import p::*;
  int r;
  c h;
  initial begin
    r = c:: obj.v;
    h = c::type_id:: create();
    h = c::type_id::create();
  end
endmodule
