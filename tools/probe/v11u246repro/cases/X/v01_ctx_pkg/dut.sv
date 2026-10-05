// § dpiTopCastResolvesByModImport246
package p;
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  typedef bit unsigned [64-1:0] addr_t;
  virtual class base;
    pure virtual function void hook(sev_e s, int n = 1);
  endclass
  class pc #(int W = 4);
    bit [W-1:0] v;
  endclass
  class impl extends base;
    bit m[sev_e];
    impl self;
    extern function void go(int severity);
    virtual function void hook(sev_e s, int n = 1); endfunction
    function void st();
      static int cnt;
      cnt++;
    endfunction
  endclass
  function void impl::go(int severity);
    addr_t addrs[];
    bit [$bits(pc#(3)::W)-1:0] w;
    this.hook(sev_e'(severity));
    hook(.s(sev_e'(severity)), .n());
    hook(sev_e'(severity), );
    if (this.self.m.exists(sev_e'(severity))) w = st.cnt;
    foreach (addrs[i]) addrs[i][7 -: 4] = {2{w[1:0]}};
    late(severity);
  endfunction
  export "DPI-C" function m_dpi;
  function void m_dpi(int severity);
    impl h;
    h.hook(sev_e'(severity));
  endfunction
  function void late(int x); endfunction
endpackage
module top;
  import p::*;
  assign imp_n = 1'b1;
  sev_e s;
endmodule
