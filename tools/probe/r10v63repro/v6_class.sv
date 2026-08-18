// r10v63 — V6: CLASS home + typedef'd/parameterised class params + a virtual
// interface neighbour, plus a package with the same shapes (the `!inPackage`
// fence) and a module that reads them.  MEASUREMENT ONLY.
function automatic integer vb6(integer value);
  return (value == 1) ? 1 : $clog2(value);
endfunction
function automatic integer sb6(integer value); return value - 1; endfunction

package pk6;
  function automatic integer pvb(integer v); return (v==1)?1:$clog2(v); endfunction
  localparam int          q_tern = pvb(16384);
  localparam int          q_sub  = 300 - 1;
  class C6 #(parameter int W = 16384);
    localparam int          c_tern = pvb(W);
    localparam logic [15:0] c_vt   = pvb(W);
    int z;
  endclass
endpackage

class D6 #(parameter int W = 16384);
  localparam int          d_tern = vb6(W);
  localparam int          d_sub  = sb6(W);
  int z;
endclass

module s_cls (output logic o);
  localparam int m_tern = vb6(16384);
  localparam int m_sub  = sb6(300);
  assign o = |{m_tern[0], m_sub[0], pk6::q_tern[0]};
endmodule

module top(output logic o1);
  s_cls u1 (.o(o1));
endmodule
