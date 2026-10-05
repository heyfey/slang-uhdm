// § patLeftoverOpCopy242
// The package holder: a package localparam built by the function (the elaborated package
// listing stamps the typedef), read by a module through an import.
package cp;
  typedef struct packed {
    logic [1:0][63:0] base;
    int unsigned n;
    bit z;
  } cfg_t;
endpackage
package bp;
  localparam cp::cfg_t U = '{base: 128'({64'h11, 64'h22}), n: unsigned'(3), z: 0};
  function automatic cp::cfg_t build(cp::cfg_t c);
    cp::cfg_t r;
    r.base = c.base;
    r.n = unsigned'(3);
    r.z = c.n && c.base;
    return r;
  endfunction
  localparam cp::cfg_t B = build(U);
endpackage
module top import bp::*; (output logic o);
  assign o = 1'b0;
endmodule
