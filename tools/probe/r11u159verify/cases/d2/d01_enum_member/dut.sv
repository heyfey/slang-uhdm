// § pkgTdCastTargetOwnView151
package p;
  typedef enum logic [1:0] {M0, M1, M2} m_e;
  typedef struct packed { m_e M; logic [3:0] W; } cfg_t;
  localparam cfg_t E = cfg_t'(0);
  function automatic cfg_t mk();
    cfg_t c;
    c.M = M2;
    c.W = 4'd9;
    return c;
  endfunction
  localparam cfg_t D = mk();
endpackage
module top(output logic [5:0] o);
  assign o = p::D ^ p::E;
endmodule
