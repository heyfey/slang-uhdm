// § hierPathSelIdxAtPath178
interface ifc;
  typedef struct { int v; } s_t;
  typedef struct { s_t w[4]; } m_t;
  m_t m;
  function automatic int g(int k); return m.w[k+1].v; endfunction
endinterface
module top; ifc i(); int r; initial r = i.g(1); endmodule
