// § elabImpSelFlatKeepsParent302
// f02: selected inside a package function body
package p;
  typedef struct packed { logic [39:0] a; logic [39:0] b; } w_t;
  localparam w_t WS = '{a: 40'd4, b: 40'd5};
  function automatic int f(); return WS.b; endfunction
endpackage
module q import p::*; (output int o);
  assign o = f();
endmodule
module dut(output int o);
  q u_q (.o(o));
endmodule
