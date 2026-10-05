// § pkgArrTdBindCopies250
// array and alias-of-keyword typedefs through named and positional calls, an empty slot, an extern task, a pure virtual prototype above and below the caller and this. paths
package p;
  typedef int i_t;
  typedef i_t al_t;
  typedef logic [3:0] a_t [2];
  typedef int q_t [$];
  virtual class vb;
    pure virtual function al_t get(a_t v, al_t k = 1);
  endclass
  class c extends vb;
    a_t m;
    q_t mq;
    extern task put(input a_t v, input al_t k);
    virtual function al_t get(a_t v, al_t k = 1);
      return al_t'(v[0]) + k + this.m[1];
    endfunction
  endclass
  task c::put(input a_t v, input al_t k);
    this.m = v;
    this.mq.push_back(k);
  endtask
endpackage
module top;
  import p::*;
  c h;
  a_t v;
  al_t r;
  initial begin
    h = new;
    v[0] = 4'd1; v[1] = 4'd2;
    h.put(.v(v), .k(3));
    r = h.get(v, );
    r = h.get(.v(v), .k(r));
  end
endmodule
