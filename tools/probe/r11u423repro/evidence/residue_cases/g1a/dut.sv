// residue (no law landed): goal-1 shape C::mk().arr[1], Surelog rejects it, see README
class C;
  int arr[4];
  static function C mk(); C c = new; return c; endfunction
endclass
module top;
  int v;
  initial v = C::mk().arr[1];
endmodule
