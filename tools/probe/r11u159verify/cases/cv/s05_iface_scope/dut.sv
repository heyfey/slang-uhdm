// § classVarInitSpan152
class C;
  int x;
  function C clone();
    C r = new;
    r.x = x;
    return r;
  endfunction
  static function C make();
    C r = new;
    return r;
  endfunction
endclass
interface bus_if;
  C c1 = new;
endinterface
module top ();
  bus_if b();
endmodule
