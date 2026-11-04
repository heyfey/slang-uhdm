// § tfArgTypeParamDefaultWriter231 — a class type parameter defaulting to an enum typedef types a method formal (uvm_enum_wrapper)
package p;
  typedef enum bit {PASSIVE=0, ACTIVE=1} ap_e;
  class wrap #(type T=ap_e);
    static function bit from_name(string name, ref T value);
      return 0;
    endfunction
  endclass
endpackage
module top;
endmodule
