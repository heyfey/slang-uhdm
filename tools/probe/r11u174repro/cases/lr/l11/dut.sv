// § elabParamLeftoverRefUnnamed174
package pk;
  typedef struct packed {
    int unsigned sw;
    int unsigned dw;
  } u_t;
  typedef struct packed {
    u_t u;
    int unsigned der;
  } c_t;
  function automatic u_t mku();
    u_t c;
    c.sw = 3;
    c.dw = 32;
    return c;
  endfunction
  function automatic c_t build(u_t uu);
    c_t c;
    c.u = uu;
    c.der = 5;
    return c;
  endfunction
  localparam u_t UC = mku();
  localparam c_t CF = build(UC);
endpackage
module leaf #(parameter int unsigned W = 1) (); endmodule
module top #(parameter pk::c_t CFG = pk::CF) ();
  leaf #(.W(CFG.u.sw)) u();
endmodule
