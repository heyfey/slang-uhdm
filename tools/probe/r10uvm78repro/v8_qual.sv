// V8 — force the COLLISION the pass never measured: a select whose OWN fullname
// Surelog sets EXPLICITLY (the `name.find("::")` branch of
// compilePartSelectRange, the mixed-separator `vmm_channel::Xtask X.bit_conv`
// family of RF-1) AND which has a NON-CONSTANT bound ref for law 2 to re-scope.
package v8_pkg;
  int unsigned pq[$];
  logic [31:0] pvec;
  class c8;
    static int unsigned sq[$];
    static logic [31:0] svec;
  endclass
  function automatic int fpkg(int b);
    int unsigned t[$];
    t = pq[0:b-1];                 // package var, bound in a package function
    return t.size();
  endfunction
  function automatic int fcls(int b);
    int unsigned t[$];
    t = c8::sq[0:b-1];             // '::'-QUALIFIED base + non-constant bound
    return t.size();
  endfunction
  function automatic logic [7:0] fclsi(int b);
    return c8::svec[b +: 8];       // '::'-qualified base, indexed
  endfunction
endpackage
module v8_qual;
  int unsigned lq[$];
  int z0, z1, z2, z3;
  logic [7:0] y0, y1;
  initial begin
    z0 = v8_pkg::fpkg(3);
    z1 = v8_pkg::fcls(2);
    y0 = v8_pkg::fclsi(1);
    lq = v8_pkg::pq[0:z0-1];       // 'pkg::'-qualified base from a MODULE scope
    y1 = v8_pkg::pvec[z0 +: 8];    // 'pkg::'-qualified indexed from a MODULE
  end
endmodule
