// § pkgArrTdListing250
// dynamic, queue and associative typedefs used in a class specialization bound, a this. path, an extern method and a pure virtual prototype
package p;
  typedef int dq_t [$];
  typedef byte da_t [];
  typedef logic [7:0] aa_t [string];
  typedef bit [3:0] ai_t [int];
  typedef bit [3:0] ex_t [5];
  virtual class base #(int N = 1);
    pure virtual function int sz(dq_t q);
  endclass
  class c #(int N = 2) extends base #(N);
    dq_t m_q;
    da_t m_d;
    aa_t m_a;
    ai_t m_i;
    extern function int sz(dq_t q);
    function void fill();
      this.m_q.push_back(N);
      this.m_d = new[N];
      this.m_a["k"] = 8'h1;
      this.m_i[3] = 4'h2;
    endfunction
  endclass
  function int c::sz(dq_t q);
    return q.size() + this.m_d.size();
  endfunction
endpackage
module top;
  import p::*;
  c #($size(ex_t)) h;
  dq_t q;
  aa_t a;
  initial begin
    h = new;
    h.fill();
    q.push_back(h.sz(q));
    a["x"] = 8'd2;
  end
endmodule
