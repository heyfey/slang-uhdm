// § ipsBasePfxScopeJoin224
package p1;
  typedef struct { logic [7:0] v; } s_t;
  class c;
    static s_t arr[4];
    static function logic [1:0] f(int i, int k);
      return arr[i].v[k+:2];
    endfunction
  endclass
endpackage
module top(output logic [1:0] o);
  assign o = p1::c::f(1, 2);
endmodule
