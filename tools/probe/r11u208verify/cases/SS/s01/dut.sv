// § tfSigningSpanFollowsCompilePath200
package p;
  function automatic integer unsigned f1(input integer signed a, input time unsigned t);
    return a + t;
  endfunction
  function automatic time signed f2(input longint unsigned l, input byte signed b);
    return l - b;
  endfunction
  class c;
    function int unsigned m(input shortint unsigned s, input int signed i);
      return s + i;
    endfunction
    static function byte signed sm(input bit signed [3:0] x);
      return x;
    endfunction
  endclass
endpackage
module s01(input integer a, output time y);
  assign y = p::f2(a, 8'sd1) + p::f1(a, 5);
endmodule
