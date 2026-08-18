// v62i — THE DELIBERATE NON-BINDS, inside a MULTIPLY-SPECIALIZED module.
// § enumNoBind13 (in-class-method body, every position) and the class-scope
// half of LAW C must still leave the reference BARE after the site-keyed
// fallback: if the patch over-binds here it is a pristine-right ->
// patched-wrong on legal SV.
module nb62 #(parameter int W = 4) (input logic clk, output logic [7:0] z);
  typedef enum logic [1:0] { NA, NB, NC } n_e;
  typedef struct packed { n_e op; logic [1:0] sz; } n_t;
  n_t nv;

  class kc62;
    n_e  m;
    int  r;
    function void mth(input n_e a);
      if (m == NB) r = 1;            // in-class-method CONDITION
      else if (a == NC) r = 2;       // in-class-method, ARG compare
      m = NA;                        // in-class-method WRITE
    endfunction
    function void oob;               // declared here, defined out of body
      m = NC;
    endfunction
  endclass

  logic p0, p1;
  assign p0 = (nv.op == NB);         // module CA (must BIND)
  always_comb p1 = (nv.op == NC);    // procedural (must BIND)
  assign z = {6'b0, p1, p0};
endmodule

module top62i (input logic clk, output logic [15:0] o);
  logic [7:0] a, b;
  nb62 #(.W(4)) u_a (.clk(clk), .z(a));
  nb62 #(.W(8)) u_b (.clk(clk), .z(b));
  assign o = {a, b};
endmodule
