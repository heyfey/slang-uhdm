// § classTdRetSharesTypedefTs200 § classTdRetVarKeepsWrittenLoc202v
class C #(type T = int);
  typedef C #(T) this_type;
  static this_type inst;
  static function this_type get();
    if (inst == null) inst = new;
    return inst;
  endfunction
endclass
typedef C #(byte) cb_t;
class F;
  function cb_t mk();
    return cb_t::get();
  endfunction
endclass
module t02; F f; endmodule
