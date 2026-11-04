// § methArgCastTsChainName246
package p;
  class pool #(type T = int);
    bit m[T];
    function bit has(T k); return m.exists(k); endfunction
  endclass
  class h #(type T = int);
    pool #(T) pl[string];
    function bit proc(int v, string id);
      return pl[id].m.exists(T'(v)) || pl[id].has(T'(v + 1));
    endfunction
  endclass
endpackage
module top;
  p::h #(byte) hh;
  initial hh = new;
endmodule
