// r11u85 n4 -- the GEN-SCOPE home inside an interface, and the interface's
// module-level home, reading the SAME nested member.  `genCaSubstAdjustW71`
// is the gen-scope home's width walk; does it already answer 64 there?
package p;
  typedef struct packed { int unsigned n; logic [7:0] m; } cfg_t;
  typedef struct packed { cfg_t inner; logic [3:0] t; } outer_t;
  localparam outer_t OUT = '{inner: '{n: 11, m: 8'h5A}, t: 4'h3};
endpackage

interface ifc #(parameter p::outer_t D = p::OUT) ();
  logic [31:0] body_nest;
  assign body_nest = D.inner.n;
  if (1) begin : gi
    logic [31:0] gen_nest;
    assign gen_nest = D.inner.n;
    logic [31:0] gen_flat;
    assign gen_flat = D.t;
  end
endinterface

module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = u_i.body_nest ^ u_i.gi.gen_nest ^ u_i.gi.gen_flat;
endmodule
