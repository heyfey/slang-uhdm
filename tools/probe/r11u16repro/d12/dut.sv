// d12 — the HOLDER / SCOPE matrix: an INTERFACE body's continuous assignment,
// a generate-FOR body, and a child instance whose def listing must stay
// symbolic while both elaborated copies fold.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  function automatic cfg_t build(int unsigned k);
    cfg_t r;
    r.n    = k;
    r.base = 64'h1000;
    return r;
  endfunction
endpackage

interface ifc #(parameter p::cfg_t C = p::build(7)) ();
  logic [31:0] o;
  assign o = C.n;
endinterface

module child #(parameter p::cfg_t C = p::build(1)) (output logic [31:0] o);
  assign o = C.n;
endmodule

module dut (output logic [31:0] a, output logic [31:0] b, output logic [127:0] g);
  localparam p::cfg_t L = p::build(4);
  ifc u_i ();
  child #(.C(p::build(9))) u_c (.o(a));
  assign b = L.n;
  genvar i;
  generate
    for (i = 0; i < 4; i++) begin : gl
      wire [31:0] gw;
      assign gw = L.n;
    end
  endgenerate
  assign g = {gl[3].gw, gl[2].gw, gl[1].gw, gl[0].gw};
endmodule
