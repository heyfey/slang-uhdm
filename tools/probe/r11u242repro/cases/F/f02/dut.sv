// § signCastLitLeftoverIsBodyOperand242
// The builder writes unsigned'(2) (the law: the leftover is the body's own literal) beside the
// f01 shape; elaborated view STRICT_NOTEQUAL -> STRICT_EQUAL.
package cp;
  localparam int NR = 16;
  typedef struct packed {
    int unsigned n;
    logic [NR-1:0][63:0] base;
    logic [NR-1:0][63:0] len;
  } ucfg_t;
  typedef struct packed {
    int unsigned n;
    logic [NR-1:0][63:0] base;
    logic [NR-1:0][63:0] len;
    bit en;
    int unsigned k;
    int m;
  } cfg_t;
endpackage
package up;
  localparam cp::ucfg_t U = '{
    n: unsigned'(2),
    base: 1024'({64'h10, 64'h20}),
    len: 1024'({64'h1000, 64'h2000, 64'h3000})
  };
endpackage
package bp;
  function automatic cp::cfg_t build(cp::ucfg_t c);
    cp::cfg_t r;
    r.n = c.n;
    r.base = c.base;
    r.len = c.len;
    r.en = c.n && c.base;
    r.k = unsigned'(2);
    r.m = 3;
    return r;
  endfunction
endpackage
module top #(parameter cp::cfg_t C = bp::build(up::U)) (output logic o);
  assign o = 1'b0;
endmodule
