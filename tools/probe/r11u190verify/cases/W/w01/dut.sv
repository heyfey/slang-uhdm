// § tfArgAggSwitchSplit180 (r11u190: a package struct typedef taken by a package CLASS method formal and by a module's package-qualified formal; the pass-176 switches alone)
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  class c;
    function logic [3:0] get(input s_t x); return x.a; endfunction
  endclass
endpackage
module top(output logic [3:0] o);
  function automatic logic [3:0] f(input p::s_t y); return y.b; endfunction
  localparam p::s_t P = '{a:4'h1, b:4'h2};
  assign o = f(P);
endmodule
