// § foreachFlatLocalRefTs238
// element kinds: packed vector, enum, struct, class handle, typedef'd queue, nested begin, task
package p;
  typedef enum {A, B} e_t;
  typedef struct packed { logic [3:0] x; } s_t;
  typedef int iq_t[$];
  class h; int v; endclass
  function int f;
    static logic [7:0] pv[$];
    static e_t ev[];
    static s_t sv[3];
    static h hv[$];
    static iq_t tq;
    int n;
    foreach (pv[i]) n += pv[i];
    foreach (ev[i]) n += ev[i];
    foreach (sv[i]) n += sv[i].x;
    foreach (hv[i]) n += hv[i].v;
    foreach (tq[i]) n += tq[i];
    begin
      foreach (pv[j]) n -= pv[j];
    end
    return n;
  endfunction
  task t;
    input int a;
    static int tv[$];
    foreach (tv[i]) tv[i] = a;
  endtask
endpackage
module top;
  int r;
  initial r = p::f();
endmodule
